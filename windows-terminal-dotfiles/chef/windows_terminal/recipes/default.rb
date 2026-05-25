# Cookbook:: windows_terminal
# Recipe:: default

settings_source = ::File.join(Chef::Config[:cookbook_path].first, 'windows_terminal', 'files', 'settings.json')
target_dir = ::File.join(ENV['LOCALAPPDATA'], 'Packages', 'Microsoft.WindowsTerminal_8wekyb3d8bbwe', 'LocalState')
target_file = ::File.join(target_dir, 'settings.json')

directory target_dir do
  recursive true
  action :create
end

cookbook_file target_file do
  source 'settings.json'
  action :create
  sensitive true
end
