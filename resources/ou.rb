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

property :path, String, required: true
property :protect, [true, false], default: true

action :create do
  unless exists?
    cmd = ''
    cmd << "$Protect = #{new_resource.protect ? '$true' : '$false'};"
    cmd << 'New-ADOrganizationalUnit'
    cmd << " -Name:\"#{new_resource.name}\""
    cmd << " -Path:\"#{new_resource.path}\""
    cmd << ' -ProtectedFromAccidentalDeletion:$Protect'

    powershell_script "Create Ou #{new_resource.name}" do
      code cmd
    end
  end
end

action_class do
  def exists?
    ldap_path = "ou=#{new_resource.name},#{new_resource.path}"
    check = Mixlib::ShellOut.new("powershell.exe -command [adsi]::Exists('LDAP://#{ldap_path}')").run_command
    check.stdout.match('True')
  end
end
