require 'mixlib/shellout'

property :name, name_attribute: true, kind_of: String, required: true
property :category, kind_of: String, default: 'Security'
property :scope, kind_of: String, default: 'Global'
property :path, kind_of: String, required: true

default_action :create

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdGroup.new(@new_resource.name)
end

action :create do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << 'New-ADGroup'
    cmd << " -GroupCategory:\"#{category}\""
    cmd << " -GroupScope:\"#{scope}\""
    cmd << " -Name:\"#{name}\""
    cmd << " -Path:\"#{path}\""
    cmd << " -SamAccountName:\"#{name}\""
    powershell_script "Create AD Group #{name}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  cmd = ''
  cmd << '$exists = $false;'
  cmd << "Try{$group = Get-ADGroup \'#{name}\'}Catch{};"
  cmd << 'if($group){$exists = $true};'
  cmd << '$exists;'
  cmd << 'Write-Output $exists'
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
