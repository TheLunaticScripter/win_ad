property :domain_name, String, required: true
property :dns_server, String
property :domain_user, String
property :domain_pswd, String
property :path, String
property :restart, [true, false], default: true

action :join_domain do
  if on_domain?
    new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << '$pswd = ConvertTo-SecureString'
    cmd << " \'#{new_resource.domain_pswd}\'"
    cmd << ' -AsPlainText'
    cmd << ' -Force;'
    cmd << '$credential = New-Object'
    cmd << " System.Management.Automation.PSCredential (\"#{new_resource.domain_user}\",$pswd);"
    cmd << 'Add-Computer'
    cmd << " -DomainName #{new_resource.domain_name}"
    cmd << ' -Credential $credential'
    cmd << " -OUPath \"#{new_resource.path}\""
    cmd << ' -Restart' if new_resource.restart
    cmd << ' -Force'
    powershell_script "Add this node to the #{new_resource.domain_name} domain." do
      code cmd
    end
  end
end

action :set_dns_server do
  if dns_servers_set?
    new_resource.updated_by_last_action(false)
  else
    cmd = ''
    cmd << "$CorrectDNS = #{new_resource.dns_server};"
    cmd << '$NIC = Get-NetAdapter | where {$_.Status -eq "Up"};'
    cmd << '$NIC | Set-DnsClientServerAddress -ServerAddresses $CorrectDNS'
    powershell_script 'Configure DNS on the node' do
      code cmd
    end
  end
end

action_class do
  def on_domain?
    cmd = ''
    cmd << '$domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name;'
    cmd << "$domain -eq \'#{new_resource.domain_name}\'"
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end

  def dns_servers_set?
    cmd = ''
    cmd << '$NIC = Get-NetAdapter | where {$_.Status -eq \"Up\"};'
    cmd << '$DnsServers = $NIC | Get-DnsClientServerAddress -AddressFamily IPv4;'
    cmd << "$CorrectDNS = #{new_resource.dns_server};"
    cmd << '(Compare-Object $DnsServers.ServerAddresses $CorrectDNS -sync 0).Length -eq 0'
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end
end
