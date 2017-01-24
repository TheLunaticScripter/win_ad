require 'mixlib/shellout'

property :domain_name, kind_of: String, name_property: true
property :restart, kind_of: [TrueClass, FalseClass], required: true, default: true
property :safe_mode_pass, kind_of: String, required: true
property :type, kind_of: String, required: true
property :domain_user, kind_of: String
property :domain_pass, kind_of: String

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdServer.new(@new_resource.domain_name)
end

def whyrun_supported?
  true
end


action :install_ad_services do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    [
      'AD-Domain-Services',
      'DNS',
      'RSAT-DNS-Server'
    ].each do |feature| 
      dsc_script "#{feature}" do
        code <<-EOH
          WindowsFeature "#{feature}"
          {
              Name = "#{feature}"
              Ensure = "Present"
          }
        EOH
      end 
    end

    cmd = create_command
    cmd << " -DomainName #{domain_name}"
    cmd << " -SafeModeAdministratorPassword (convertto-securestring '#{safe_mode_pass}' -asplaintext -Force)"
    cmd << ' -Force:$true'
    cmd << ' -NoRebootOnCompletion' if !restart
	#cmd << format_options(options)
    
    powershell_script "create_domain_#{domain_name}" do
      code cmd
    end

    @new_resource.updated_by_last_action(true)
  end
end

def exists?
  ldap_path = domain_name.split('.').map! { |k| "dc=#{k}" }.join(',')
  check = Mixlib::ShellOut.new("powershell.exe -command [adsi]::Exists('LDAP://#{ldap_path}')").run_command
  check.stdout.match('True')
end
 
def create_command
  cmd = ''
  if type != 'forest'
    cmd << "$secpasswd = ConvertTo-SecureString '#{domain_pass}' -AsPlainText -Force;"
    cmd << "$mycreds = New-Object System.Management.Automation.PSCredential  ('#{domain_user}', $secpasswd);"
  end
  case type
  when 'forest'
    cmd << 'Install-ADDSForest'
  when 'domain'
    cmd << 'Install-ADDSDomain -Credential $mycreds'
  when 'replica'
    cmd << 'Install-ADDSDomainController -Credential $mycreds'
  end
end
