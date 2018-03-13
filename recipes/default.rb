#
# Cookbook:: win_ad
# Recipe:: default
#
# Author:: John Snow (<jsnow@chef.io>)
#
# Copyright:: 2016-2018, John Snow
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
  user_name 'chef'
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
