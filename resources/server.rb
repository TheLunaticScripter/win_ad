property :domain_name, String, required: true
property :restart, [true, false], default: true
property :safe_mode_pass, String, required: true
property :type, String, required: true
property :domain_user, String
property :domain_pass, String

action :install_ad_services do
  unless exists?
    [
      'AD-Domain-Services',
      'DNS',
      'RSAT-DNS-Server',
    ].each do |feature|
      dsc_script feature do
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
    cmd << " -DomainName #{new_resource.domain_name}"
    cmd << " -SafeModeAdministratorPassword (convertto-securestring '#{new_resource.safe_mode_pass}' -asplaintext -Force)"
    cmd << ' -Force:$true'
    cmd << ' -NoRebootOnCompletion'

    powershell_script "create_domain_#{new_resource.domain_name}" do
      code cmd
      notifies :reboot_now, 'reboot[reboot_for_ad]' if new_resource.restart
    end

    reboot 'reboot_for_ad' do
      action :nothing
      reason 'Rebooting server to complete install of AD.'
      delay_mins 1
    end
  end
end

action_class do
  def exists?
    ldap_path = new_resource.domain_name.split('.').map! { |k| "dc=#{k}" }.join(',')
    check = Mixlib::ShellOut.new("powershell.exe -command [adsi]::Exists('LDAP://#{ldap_path}')").run_command
    check.stdout.match('True')
  end

  def create_command
    cmd = ''
    if new_resource.type != 'forest'
      cmd << "$secpasswd = ConvertTo-SecureString '#{new_resource.domain_pass}' -AsPlainText -Force;"
      cmd << "$mycreds = New-Object System.Management.Automation.PSCredential  ('#{new_resource.domain_user}', $secpasswd);"
    end
    case new_resource.type
    when 'forest'
      cmd << 'Install-ADDSForest'
    when 'domain'
      cmd << 'Install-ADDSDomain -Credential $mycreds'
    when 'replica'
      cmd << 'Install-ADDSDomainController -Credential $mycreds'
    end
  end
end
