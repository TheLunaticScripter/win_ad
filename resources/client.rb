property :name, kind_of: String, name_property: true
property :domain_name, kind_of: String
property :dns_server, kind_of: String
property :domain_user, kind_of: String
property :domain_pswd, kind_of: String
property :path, kind_of: String
property :restart, kind_of: [TrueClass, FalseClass], default: true

default_action :join_domain

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdServer.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :join_domain do 
  if on_domain?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << '$pswd = ConvertTo-SecureString'
    cmd << " \'#{domain_pswd}\'"
    cmd << ' -AsPlainText'
    cmd << ' -Force;'
    cmd << '$credential = New-Object'
    cmd << " System.Management.Automation.PSCredential (\"#{domain_user}\",$pswd);"
    cmd << 'Add-Computer'
    cmd << " -DomainName #{domain_name}"
    cmd << " -Credential $credential"
    cmd << " -OUPath \"#{path}\""
    cmd << ' -Restart' if restart
    cmd << ' -Force'
    powershell_script "Add this node to the #{domain_name} domain." do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

action :set_dns_server do
  if dns_servers_set?
    @new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "$CorrectDNS = #{dns_server};"
    cmd << '$NIC = Get-NetAdapter | where {$_.Status -eq "Up"};'
    cmd << '$NIC | Set-DnsClientServerAddress -ServerAddresses $CorrectDNS'
    powershell_script 'Configure DNS on the node' do
      code cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def on_domain?
  cmd = ''
  cmd << '$domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name;'
  cmd << "$domain -eq \'#{domain_name}\'"
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end

def dns_servers_set?
  cmd = ''
  cmd << '$NIC = Get-NetAdapter | where {$_.Status -eq \"Up\"};'
  cmd << '$DnsServers = $NIC | Get-DnsClientServerAddress -AddressFamily IPv4;'
  cmd << "$CorrectDNS = #{dns_server};"
  cmd << '(Compare-Object $DnsServers.ServerAddresses $CorrectDNS -sync 0).Length -eq 0'
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
