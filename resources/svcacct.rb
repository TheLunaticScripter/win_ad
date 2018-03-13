#
# Cookbook:: win_ad
# Resource:: svcacct
#
# Author:: John Snow (<jsnow@chef.io>)
#
# Copyright:: 2016-2018, John Snow
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

property :path, String, required: true
property :pswd, String, required: true

action :create do
  unless exists?
    cmd = ''
    cmd << "$password = ConvertTo-SecureString \'#{new_resource.pswd}\' -AsPlainText -Force;"
    cmd << 'New-ADUser'
    cmd << " -DisplayName #{new_resource.name}"
    cmd << " -Name #{new_resource.name}"
    cmd << " -Path \'#{new_resource.path}\'"
    cmd << " -SamAccountName #{new_resource.name}"
    cmd << " -UserPrincipalName #{new_resource.name}@$env:USERDNSDOMAIN"
    cmd << ' -CannotChangePassword $true'
    cmd << ' -AccountPassword $password'
    cmd << ' -ChangePasswordAtLogon $false'
    cmd << ' -PasswordNeverExpires $true'
    cmd << ' -Enabled $true'
    powershell_script "Create Service Account #{new_resource.name}" do
      code cmd
    end
  end
end

action_class do
  def exists?
    cmd = ''
    cmd << '$user = $null;'
    cmd << "$user = Get-ADUser #{new_resource.name};"
    cmd << '$user -ne $null'
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end
end
