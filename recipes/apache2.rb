#
# Cookbook Name:: site-demo
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
# Install Apache
######################################
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_expires"
include_recipe "apache2::mod_headers"

######################################
# Configure Virtual Host
######################################
websites.each do |host|
  template "#{host}" do
    path "#{node[:apache][:dir]}/sites-available/#{host}"
    source "apache2-site-template.erb"
    owner node[:apache][:user]
    group node[:apache][:group]
    mode 0644
    variables(
      :log_dir => "/var/www/vhosts/#{host}/log",
      :document_root => "/var/www/vhosts/#{host}/www",
      :server_name => "#{host}"
    )
  end

  # Enable Virtual Host
  apache_site "#{host}" do
    enable true
    notifies  :restart, 'service[apache2]'
  end
end

# Override default
#template "#{node[:apache][:dir]}/sites-available/default" do
#  source "apache2-site-default.erb"
#  owner node[:apache][:user]
#  group node[:apache][:group]
#  mode 0644
#  notifies :restart, resources(:service => "apache2")
#end

# For now disable website "master.demo.typo3.org"
apache_site "master.demo.typo3.org" do
  enable false
  notifies  :restart, 'service[apache2]'
end