property :group_name, String, required: true
property :user_name, String, required: true
property :type, String, default: 'user'

action :add do
  if exists?
    new_resource.updated_by_last_action(false)
  else
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
