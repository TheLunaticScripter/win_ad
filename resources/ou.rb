property :path, String, required: true
property :protect, [true, false], default: true

action :create do
  if exists?
    new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "$Protect = #{new_resource.protect};"
    cmd << 'New-ADOrganizationalUnit'
    cmd << " -Name:\"#{new_resource.name}\""
    cmd << " -Path:\"#{new_resource.path}\""
    cmd << ' -ProtectedFromAccidentalDeletion:$Protect'

    powershell_script "Create Ou #{new_resource.name}" do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

action_class do
  def exists?
    ldap_path = "ou=#{new_resource.name},#{new_resource.path}"
    check = Mixlib::ShellOut.new("powershell.exe -command [adsi]::Exists('LDAP://#{ldap_path}')").run_command
    check.stdout.match('True')
  end
end
