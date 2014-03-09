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

