#
# Cookbook Name:: site-demotypo3org
#
# Copyright 2012, TYPO3 Association
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
#

##########################################
# Website list
##########################################
websites = %w{master.demo.typo3.org demo.typo3.org}

######################################
# Install Nginx
######################################
include_recipe "nginx"

# Overwrite website "default"
template "nginx-default" do
  path "#{node[:nginx][:dir]}/sites-available/default"
  source "nginx-site-default.erb"
  owner "root"
  group "root"
  mode 0644
end

link "#{node[:nginx][:dir]}/sites-enabled/default" do
  to "#{node[:nginx][:dir]}/sites-available/default"
  notifies  :restart, 'service[nginx]'
end

# Create new directory "conf.location.d"
directory "#{node[:nginx][:dir]}/conf.location.d" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Write "main" configuration
template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx-conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies  :restart, 'service[nginx]'
end

# Write default location configuration
%w{default deny expires php robots}.each do |template|
  template "#{template}.conf" do
    path "#{node[:nginx][:dir]}/conf.location.d/#{template}.conf"
    source "nginx-conf-#{template}.erb"
    owner "root"
    group "root"
    mode 0644
  end
end

# Write virtual host files and enable symlink
websites.each_with_index do |host, index|

  # Nginx virtual host configuration
  template "nginx-#{host}" do
    path "#{node[:nginx][:dir]}/sites-available/#{host}"
    source "nginx-site-template.erb"
    owner "root"
    group "root"
    mode 0644
    fpm_port = index + 9000
    variables(
      :domain => "#{host}",
      :fpm_port => "#{fpm_port}"
    )
  end

  link "#{node[:nginx][:dir]}/sites-enabled/#{host}" do
    to "#{node[:nginx][:dir]}/sites-available/#{host}"
    notifies  :restart, 'service[nginx]'
  end
end

# For now disable website "master.demo.typo3.org"
link "#{node[:nginx][:dir]}/sites-enabled/master.demo.typo3.org" do
  action :delete
  only_if "test -L #{node[:nginx][:dir]}/sites-enabled/master.demo.typo3.org"
  notifies  :restart, 'service[nginx]'
end
