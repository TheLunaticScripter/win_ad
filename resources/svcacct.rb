property :path, String, required: true
property :pswd, String, required: true

action :create do
  if exists?
    new_resource.updated_by_last_action(false)
  else
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
