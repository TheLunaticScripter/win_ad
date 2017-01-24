# win_ad

Windows Active Directory (AD) and Domain Name Service (DNS) Cookbook
=============================================

Requirements
------------
#### Platforms
* Windows Server 2012 (R1, R2)

#### Chef
- Chef 12+

Usage
-----

### Purpose
This is a library cookbook with custom resources to create and manage Windows AD and DNS

Recipes
-------

### default.rb
Demonstrates how to use the resources in this cookbook and used for test-kitchen.
This will be deprecated at some point favor of the test cookbook method.

Custom Resources
----------------

### win_ad_client
Add a Client to a domain, or Set the DNS Server search list on the server

#### Actions
- 'join_domain' - Join a client to a domain
- 'set_dns_server' - Set the DNS Server search list

#### Properties
- 'domain_name' - Name of the domain the client will be joined tools
- 'dns_server' - List of DNS Servers, NOTE: Format is "'10.0.0.1','10.0.0.2'" for more than one server
- 'domain_user' - User name of a Domain user who can join the client to the domain
- 'domain_pswd' - Password of the user who can join the client to the domain
- 'path' - OU path the computer will be added to.
- 'restart' - Whether client restarts after being added. True or False value

#### Examples
Join a Computer to the foo.local domain

```
win_ad_client 'Join computer to foo.local' do
  action :join_domain
  domain_name 'foo.local'
  domain_user 'foo.local\joe.bob'
  domain_pswd 'super_secret_password123'
  path 'OU=Testing,DC=foo,DC=local'
  restart true
end
```

Set DNS search server

```
win_ad_client 'Set DNS Servers' do
  action :set_dns_server
  dns_server "'10.0.0.1','10.0.0.2'"
end
```

### win_ad_dns
Creates an A record, MX record, SRV record, or CName record in Windows DNS

#### Actions
- 'create' - Create the record

#### Properties
- 'name'       - Host Name, or service name for the record being created
- 'zone_name'  - DNS Zone the record will be created in
- 'record_type' - Type of record being created (note: valid entries are 'A', 'MX', 'CName', and 'SRV')
- 'allow_update_any' - Boolean allows the record to be updated by any authenticated user/system
- 'ipv4_address' - IP Address for the A record
- 'create_ptr' - Boolean if the ptr record should be created with the A record
- 'host_name_alias' - Alias for the CName record
- 'mail_exchange' - Mail address for the MX record
- 'preference' - Preference for the MX record
- 'host_name' - The FQDN of the host for the SRV record
- 'port' - The port number of the service for the SRV record
- 'priority' - The priority for the SRV record
- 'weight' - The weight for the SRV record

#### Examples
Create an A record  

```
win_ad_dns 'server-name' do
  zone_name 'foo.local'
  ipv4_address '10.0.0.2'
  create_ptr true
end
```

Create a CName record

```
win_ad_dns 'alias' do
  record_type 'CName'
  zone_name 'foo.local'
  host_name_alias 'host.foo.local'
end
```

Create a MX record

```
win_ad_dns 'foo.local' do
  record_type 'MX'
  zone_name 'foo.local'
  mail_exchange 'mail.foo.local'
  preference 10
end
```

Create a SRV record

```
win_ad_dns 'service_name' do
  record_type 'SRV'
  zone_name 'foo.local'
  host_name 'server1.foo.local'
  port 5555
  priority 0
  weight 0
end
```

### win_ad_group
Manages AD Security Groups

#### Actions
- 'create' - Creates a new AD Groups

#### Properties
- 'name' - Name of the group being created it can contain spaces
- 'category' - Type of Group being created. Valid options are Security and Distribution. Default is Security.
- 'scope' - The scope the group will apply to. Valid options are Domain local, Global, and Universal. Default is Global.
- 'path' - The location the group will be created in AD. Format is "OU=OU Name,DC=foo,DC=local"

#### Examples
Create a new Global Security Group called Test Group

```
win_ad_group 'Test Group' do
  path 'OU=Groups,DC=foo,DC=local'
end
```

Create a new Universal Distribution Group called UD Group

```
win_ad_group 'UD Group' do
  category 'Distribution'
  scope 'Universal'
  path 'OU=Groups,DC=foo,DC=local'
end
```

### win_ad_group_member
Adds Users to a Security or Distribution Group in AD

#### Actions
- 'add' - Add a User to a Group

#### Properties
- 'group_name' - Name of the group the User is being added to
- 'user_name' - Name of the User being added to the group.
- 'type' - Type of object to be added as a member. Valid options are user, group, or computer.

#### Examples
Add a user joe.bob to the Test Group

```
win_ad_group_member 'Add joe.bob to Test Group' do
  group_name 'Test Group'
  user_name 'joe.bob'
  type 'user'
end
```

### win_ad_ou
Creates Organizational Units (OU) in AD

#### Actions
- 'create' - Creates an OU

#### Properties
- 'name' - Name of the OU to be created
- 'path' - OU or Folder where the OU will be created
- 'protect' - Boolean wether to protect the OU from accidental deletion

#### Examples
Create the Testing OU at the root of the Domain

```
win_ad_ou 'Testing' do
  path 'DC=foo,DC=local'
end
```

### win_ad_server
Installs core AD and DNS Features. Creates a Forest, child domain, or adds a replica server to an existing domain.

#### Actions
- 'install_ad_services' - Installs AD and DNS and performs the necessary post feature install domain commands.

#### Properties
- 'domain_name' - Name of the domain being created or joined
- 'restart' - Boolean wether the install should be allowed to restart after complete
- 'safe_mode_pass' - Safe Mode Password for the Domain
- 'type' - Type of Domain Controller being created. Valid options are forest, domain, and replica
- 'domain_user' - User name of a domain user who can join a replica domain controller to the domain
- 'domain_pass' - Password of the Domain user to join a replica domain controller to the domain

#### Examples
Create the foo.local forest

```
win_ad_server 'foo.local' do
  domain_name 'foo.local'
  safe_mode_pass 'super_secret_password123'
  type 'forest'
end
```

Create a replica Domain Controller

```
win_ad_server 'foo.local' do
  domain_name 'foo.local
  safe_mode_pass 'super_secret_password123'
  domain_user 'foo.local\username'
  domain_pass 'user_password123'
  type 'replica'
end
```

### win_ad_svcacct
Create a Service Account in AD

#### Actions
- 'create' - Create a Service Account

#### Properties
- 'name' - Name of the Service Account to be created
- 'path' - OU or Folder where the Service account will be created
- 'pswd' - Password for the service account

#### Examples
Create a Service Account named Test_Svc

```
win_ad_svcacct 'Test_Svc' do
  path 'OU=Service Accounts,DC=foo,DC=local'
  pswd 'super_secret_password123'
end 
```

### win_ad_tools
Installs the Remote Server Adminstrations Tools (RSAT) tools need to manage AD and DNS

#### Actions
- 'install' - Installs the RSAT for AD and DNS

#### Examples
Use in a recipe

```
win_ad_tools 'Install RSAT'
```

License & Authors
-----------------
- Author:: John Snow (thelunaticscripter@outlook.com)
- Author:: Nestor Rentas (nestor.rentas.ctr@socom.mil)

```text
Copyright 2016, TheLunaticScripter.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License
