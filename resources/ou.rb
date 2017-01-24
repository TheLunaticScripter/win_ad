require 'mixlib/shellout'

# Build a Organization Unit in AD
property :name, name_attribute: true, kind_of: String, required: true
property :path, kind_of: String, required: true
property :protect, kind_of: [TrueClass, FalseClass], default: true

default_action :create

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdOu.new(@new_resource.name)
end

action :create do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "$Protect = #{protect};"
    cmd << 'New-ADOrganizationalUnit'
    cmd << " -Name:\"#{name}\""
    cmd << " -Path:\"#{path}\""
    cmd << ' -ProtectedFromAccidentalDeletion:$Protect'

    powershell_script "Create Ou #{name}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  ldap_path = "ou=#{name},#{path}"
  check = Mixlib::ShellOut.new("powershell.exe -command [adsi]::Exists('LDAP://#{ldap_path}')").run_command
  check.stdout.match('True')
end
