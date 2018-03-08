#
# Cookbook Name:: win_ad
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install Windows Active Directory Services
win_ad_server 'Build foo.local' do
  action :install_ad_services
  domain_name 'foo.local'
  safe_mode_pass '!QAZSE$1qazse4'
  type 'forest'
end

win_ad_tools 'Install RSAT tools'

win_ad_ou 'Testing' do
  path 'DC=foo,DC=local'
end

win_ad_group 'Test Group' do
  path 'OU=Testing,DC=foo,DC=local'
end

win_ad_group 'Test Group 2' do
  path 'OU=Testing,DC=foo,DC=local'
end

win_ad_group_member 'Test Group Member' do
  group_name 'Test Group'
  user_name 'Administrator'
  type 'user'
end

win_ad_group_member 'Test Group Member add Group' do
  group_name 'Test Group'
  user_name 'Test Group 2'
  type 'group'
end

win_ad_svcacct 'Test_Svc' do
  path 'OU=Testing,DC=foo,DC=local'
  pswd '!QAZSE$1qazse4'
end

win_ad_dns 'test-A' do
  zone_name 'foo.local'
  ipv4_address '10.0.0.8'
  create_ptr false
end

win_ad_dns 'cname-alias' do
  zone_name 'foo.local'
  host_name_alias 'test-A.foo.local'
  record_type 'CName'
end

win_ad_dns 'foo.local' do
  record_type 'MX'
  zone_name 'foo.local'
  mail_exchange 'mail.foo.local'
  preference 10
end

win_ad_dns 'service' do
  record_type 'SRV'
  zone_name 'foo.local'
  host_name 'test-A.foo.local'
  port 5555
  priority 0
  weight 0
end
