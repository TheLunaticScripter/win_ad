require 'mixlib/shellout'

property :name, name_attribute: true, kind_of: String, required: true
property :path, kind_of: String, required: true
property :pswd, kind_of: String, required: true

default_action :create

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdSvcacct.new(@new_resource.name)
end

action :create do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "$password = ConvertTo-SecureString \'#{pswd}\' -AsPlainText -Force;"
    cmd << "New-ADUser"
    cmd << " -DisplayName #{name}"
    cmd << " -Name #{name}"
    cmd << " -Path \'#{path}\'"
    cmd << " -SamAccountName #{name}"
    cmd << " -UserPrincipalName #{name}@$env:USERDNSDOMAIN"
    cmd << ' -CannotChangePassword $true'
    cmd << ' -AccountPassword $password'
    cmd << ' -ChangePasswordAtLogon $false'
    cmd << ' -PasswordNeverExpires $true'
    cmd << ' -Enabled $true'
    powershell_script "Create Service Account #{name}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  cmd = ''
  cmd << '$user = $null;'
  cmd << "$user = Get-ADUser #{name};"
  cmd << "$user -ne $null"
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
