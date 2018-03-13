#
# Cookbook:: win_ad
# Resource:: group_member
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

property :group_name, String, required: true
property :user_name, String, required: true
property :type, String, default: 'user'

action :add do
  unless exists?
    cmd = create_cmd
    cmd << 'Set-AdGroup'
    cmd << " -Identity \"#{new_resource.group_name}\""
    cmd << ' -Add @{\'Member\'=$object.DistinguishedName}'
    powershell_script "Add #{new_resource.user_name} to group #{new_resource.group_name}" do
      code cmd
    end
  end
end

action_class do
  def exists?
    cmd = ''
    cmd << "(Get-ADGroupMember \'#{new_resource.group_name}\' |"
    cmd << " where {$_.SamAccountName -eq \'#{new_resource.user_name}\'}).SamAccountName"
    cmd << " -eq \'#{new_resource.user_name}\'"
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end

  def create_cmd
    cmd = ''
    case new_resource.type
    when 'user'
      cmd << "$object = Get-ADUser \'#{new_resource.user_name}\' -Properties DistinguishedName;"
    when 'group'
      cmd << "$object = Get-ADGroup \'#{new_resource.user_name}\' -Properties DistinguishedName;"
    when 'computer'
      cmd << "$object = Get-ADComputer \'#{new_resource.user_name}\' -Properties DistinguishedName;"
    else
      Chef::Log.fatal("The group member of type #{new_resource.type} is not supported please use user, group or computer.")
    end
  end
end
