require 'mixlib/shellout'

property :name, name_attribute: true, kind_of: String, required: true
property :group_name, kind_of: String, required: true
property :user_name, kind_of: String, required: true
property :type, kind_of: String, required: true, default: 'user'

default_action :add

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdGroupMemeber.new(@new_resource.name)
end

action :add do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    cmd = create_cmd
    cmd << "Set-AdGroup"
    cmd << " -Identity \"#{group_name}\""
    cmd << ' -Add @{\'Member\'=$object.DistinguishedName}'
    powershell_script "Add #{user_name} to group #{group_name}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  cmd = ''
  cmd << "(Get-ADGroupMember \'#{group_name}\' |"
  cmd << " where {$_.SamAccountName -eq \'#{user_name}\'}).SamAccountName"
  cmd << " -eq \'#{user_name}\'"
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end

def create_cmd
  cmd = ''
  case type
  when 'user'
    cmd << "$object = Get-ADUser \'#{user_name}\' -Properties DistinguishedName;"
  when 'group'
    cmd << "$object = Get-ADGroup \'#{user_name}\' -Properties DistinguishedName;"
  when 'computer'
    cmd << "$object = Get-ADComputer \'#{user_name}\' -Properties DistinguishedName;"
  else
    Chef::Log.fatal("The group member of type #{type} is not supported please use user, group or computer.")
  end
end
