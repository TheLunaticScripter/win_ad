#
# Cookbook:: win_ad
# Resource:: group
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

property :category, String, default: 'Security'
property :scope, String, default: 'Global'
property :path, String, required: true

action :create do
  unless exists?
    cmd = ''
    cmd << 'New-ADGroup'
    cmd << " -GroupCategory:\"#{new_resource.category}\""
    cmd << " -GroupScope:\"#{new_resource.scope}\""
    cmd << " -Name:\"#{new_resource.name}\""
    cmd << " -Path:\"#{new_resource.path}\""
    cmd << " -SamAccountName:\"#{new_resource.name}\""
    powershell_script "Create AD Group #{new_resource.name}" do
      code cmd
    end
  end
end

action_class do
  def exists?
    cmd = ''
    cmd << '$exists = $false;'
    cmd << "Try{$group = Get-ADGroup \'#{new_resource.name}\'}Catch{};"
    cmd << 'if($group){$exists = $true};'
    cmd << '$exists;'
    cmd << 'Write-Output $exists'
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end
end
