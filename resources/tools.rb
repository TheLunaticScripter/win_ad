property :name, kind_of: String, name_property: true

default_action :install

def whyrun_supported?
  true
end

action :install do
  %w(
    RSAT-AD-Tools
    RSAT-AD-PowerShell
    RSAT-ADDS
    RSAT-AD-AdminCenter
    RSAT-DNS-Server
  ).each do |feature|
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
end
