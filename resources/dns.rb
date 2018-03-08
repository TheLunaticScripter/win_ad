property :zone_name, String, required: true
property :record_type, String, required: true, default: 'A'
property :allow_update_any, [true, false], default: true
property :ipv4_address, String
property :create_ptr, [true, false], default: true
property :host_name_alias, String
property :mail_exchange, String
property :preference, Integer
property :host_name, String
property :port, Integer
property :priority, Integer
property :weight, Integer

action :create do
  if exists?
    new_resource.updated_by_last_action(false)
  else
    powershell_script "Create #{new_resource.record_type} record in DNS." do
      code create_cmd
    end
  end
end

def create_cmd
  cmd = ''
  cmd << 'Add-DnsServerResourceRecord'
  cmd << " -ZoneName #{new_resource.zone_name}"
  cmd << " -Name #{new_resource.name}"
  case record_type
  when 'A'
    cmd << ' -A'
    cmd << " -IPv4Address #{new_resource.ipv4_address}"
    cmd << ' -CreatePtr' if new_resource.create_ptr
  when 'MX'
    cmd << ' -Mx'
    cmd << " -MailExchange #{new_resource.mail_exchange}"
    cmd << " -Preference #{new_resource.preference}"
  when 'CName'
    cmd << ' -CName'
    cmd << " -HostNameAlias #{new_resource.host_name_alias}"
  when 'SRV'
    cmd << ' -Srv'
    cmd << " -DomainName #{new_resource.host_name}"
    cmd << " -Port #{new_resource.port}"
    cmd << " -Priority #{new_resource.priority}"
    cmd << " -Weight #{new_resource.weight}"
  else
    cmd = ''
    Chef::Log.error("The record_type of #{new_resource.record_type} is not vaild.")
  end
  cmd
end

action_class do
  def exists?
    cmd = ''
    cmd << '$record = Get-DnsServerResourceRecord'
    cmd << " -ZoneName #{new_resource.zone_name}"
    cmd << " -Name #{new_resource.name}"
    cmd << " -RRType #{new_resource.record_type};"
    cmd << '$record -ne $null'
    check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
    check.stdout.match('True')
  end
end
