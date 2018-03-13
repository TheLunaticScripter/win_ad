# # encoding: utf-8

# Inspec test for recipe win_ad::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

# Validate Windows Features
describe windows_feature('AD-Domain-Services') do
  it { should be_installed }
end

describe windows_feature('RSAT-AD-Tools') do
  it { should be_installed }
end

describe windows_feature('DNS') do
  it { should be_installed }
end

describe windows_feature('RSAT-DNS-Server') do
  it { should be_installed }
end

# Validate Domain Exists
script = <<-EOH
  Try{
    Import-Module ActiveDirectory
    $adminpswd = ConvertTo-SecureString '!QAZSE$1qazse4' -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ("Administrator",$adminpswd)
    $domain = Get-ADDomain -Identity foo.local -Credential $credential
  }
  catch{}
  $domain -eq $null
EOH

describe powershell(script) do
  its('strip') { should eq 'False'}
end
