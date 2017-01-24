property :name, name_attribute: true, kind_of: String, required: true
property :zone_name, kind_of: String, required: true
property :record_type, kind_of: String, required: true, default: 'A'
property :allow_update_any, kind_of: [TrueClass, FalseClass], default: true
property :ipv4_address, kind_of: String
property :create_ptr, kind_of: [TrueClass, FalseClass], default: true
property :host_name_alias, kind_of: String
property :mail_exchange, kind_of: String
property :preference, kind_of: Fixnum
property :host_name, kind_of: String
property :port, kind_of: Fixnum
property :priority, kind_of: Fixnum
property :weight, kind_of: Fixnum

default_action :create

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::WindowsAdDns.new(@new_resource.name)
end

action :create do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    powershell_script "Create #{record_type} record in DNS." do
      code create_cmd
    end
    @new_resource.updated_by_last_action(true)
  end
end

def create_cmd
  cmd = ''
  cmd << 'Add-DnsServerResourceRecord'
  cmd << " -ZoneName #{zone_name}"
  cmd << " -Name #{name}"
  case record_type
  when 'A'
    cmd << ' -A'
    cmd << " -IPv4Address #{ipv4_address}"
    if create_ptr == true
      cmd << " -CreatePtr"
    end
  when 'MX'
    cmd << ' -Mx'
    cmd << " -MailExchange #{mail_exchange}"
    cmd << " -Preference #{preference}"
  when 'CName'
    cmd << ' -CName'
    cmd << " -HostNameAlias #{host_name_alias}"
  when 'SRV'
    cmd << ' -Srv'
    cmd << " -DomainName #{host_name}"
    cmd << " -Port #{port}"
    cmd << " -Priority #{priority}"
    cmd << " -Weight #{weight}"
  else
    cmd = ''
    Chef::Log.error("The record_type of #{record_type} is not vaild.")
  end
  cmd
end

def exists?
  cmd = ''
  cmd << '$record = Get-DnsServerResourceRecord'
  cmd << " -ZoneName #{zone_name}"
  cmd << " -Name #{name}"
  cmd << " -RRType #{record_type};"
  cmd << '$record -ne $null'
  check = Mixlib::ShellOut.new("powershell.exe -command \"& {#{cmd}}\"").run_command
  check.stdout.match('True')
end
