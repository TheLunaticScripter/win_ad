property :category, String, default: 'Security'
property :scope, String, default: 'Global'
property :path, String, required: true

action :create do
  if exists?
    new_resource.updated_by_last_action(false)
  else
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
