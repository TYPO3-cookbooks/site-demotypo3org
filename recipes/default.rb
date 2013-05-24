#
# Cookbook Name:: site-demotypo3org
# Recipe:: default
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

# Configure Virtual Host
## @todo remove VH masterdemotypo3org + database demotypo3org mastertypo3org
##include_recipe "site-demotypo3org::base" @todo remove me
include_recipe "site-demotypo3org::iptables"
include_recipe "site-demotypo3org::imagemagick"
include_recipe "site-demotypo3org::mysql"
include_recipe "site-demotypo3org::php5"

# Varnish introduces a cache effect that would imply a special TYPO3 extension to deal with.
#include_recipe "site-demotypo3org::php5-fpm"
#include_recipe "site-demotypo3org::nginx"
#include_recipe "site-demotypo3org::varnish"

include_recipe "site-demotypo3org::apache2"
#include_recipe "site-demotypo3org::introduction-package" @todo remove me


######################################
# GENERATE SCRIPT THAT RETURNS TIME
######################################


file "/var/www/vhosts/demo.typo3.org/www/time.php" do

  owner "root"
  group "root"
  mode "0755"
  action :create
  content <<-EOF
<?php
header('Access-Control-Allow-Origin: *');
date_default_timezone_set("UTC");
echo date("c");
?>
  EOF
end

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

packages = [
    {
        :user => 'demotypo3org',
        :host => 'demo.typo3.org',
    }, {
        :user => 'demotypo3org',
        :host => 'introduction.typo3cms.demo.typo3.org',
        :packageName => 'introduction',
        :database => 'introduction',
        :packageInstaller => 'https://github.com/fudriot/PackageInstaller.git',
    }, {
        :user => 'demotypo3org',
        :host => 'bootstrap.typo3cms.demo.typo3.org',
        :packageName => 'bootstrap',
        :database => 'bootstrap',
        :packageInstaller => 'https://github.com/fudriot/PackageInstaller.git',
    }, {
        :user => 'demotypo3org',
        :host => 'government.typo3cms.demo.typo3.org',
        :packageName => 'government',
        :database => 'government',
        :packageInstaller => 'https://github.com/fudriot/PackageInstaller.git',
    }
]

packages.each { |package|

  ######################################
  # Create user and default directories
  ######################################

  user "#{package[:user]}" do
    comment 'User for demo.typo3.org Virtual Host'
    shell '/bin/bash'
  end

  if package[:host]
    %w{home log www core}.each do |dir|
      directory "/var/www/vhosts/#{package[:host]}/#{dir}" do
        owner package[:user]
        group 'root'
        mode '0755'
        recursive true
        action :create
      end
    end
  end

  ######################################
  # Configure Virtual Host
  ######################################

  if package[:host]
    template "#{package[:host]}" do
      path "#{node[:apache][:dir]}/sites-available/#{package[:host]}"
      source 'apache2-site-template.erb'
      owner node[:apache][:user]
      group node[:apache][:group]
      mode 0644
      variables(
          :log_dir => "/var/www/vhosts/#{package[:host]}/log",
          :document_root => "/var/www/vhosts/#{package[:host]}/www",
          :server_name => "#{package[:host]}"
      )
    end

    # Enable virtual host
    apache_site "#{package[:host]}" do
      enable true
      notifies :restart, 'service[apache2]'
    end
  end

  ######################################
  # Configure database
  ######################################

  if package[:database]

    # Generate password and attach the info to the node
    ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
    node.set_unless[:mysql][:users][package[:database]][:password] = secure_password

    # Create DB + set User permission
    begin
      gem_package "mysql" do
        action :install
      end
      Gem.clear_paths
      require 'mysql'
      m=Mysql.new("localhost", "root", node['mysql']['server_root_password'])

      if m.list_dbs.include?(package[:database]) == false
        # create database
        mysql_database "#{package[:database]}" do
          connection mysql_connection_info
          action :create
        end

        # create user
        mysql_database_user "#{package[:database]}" do
          connection mysql_connection_info
          password node[:mysql][:users][package[:database]][:password]
          action :create
        end

        # Grant user
        mysql_database_user "#{package[:database]}" do
          connection mysql_connection_info
          password node[:mysql][:users][package[:database]][:password]
          database_name package[:database]
          host '%'
          privileges [:select, :update, :insert, :alter, :index, :create, :drop, :delete]
          action :grant
        end
      end
    rescue LoadError
      Chef::Log.info("Missing gem 'mysql'")
    end
  end

  ######################################
  # Configuration package installer
  ######################################

  if package[:packageInstaller]
    bash 'clone-package-installer' do
      user package[:user]
      group package[:user]
      cwd "/var/www/vhosts/#{package[:host]}/home"
      code <<-EOH
      git clone https://github.com/fudriot/PackageInstaller.git
      EOH
      not_if { ::File.exists? "/var/www/vhosts/#{package[:host]}/home/PackageInstaller" }
    end
  end

  if package[:packageInstaller]
    bash 'pull-package-installer-and-install-dependencies' do
      user package[:user]
      group package[:user]
      cwd "/var/www/vhosts/#{package[:host]}/home/PackageInstaller"
      code <<-EOH
      git pull origin master

      # Download composer if not yet present
      if [ ! -f composer.phar ];
      then
        curl http://getcomposer.org/installer | php
      fi
      php composer.phar install
      EOH
      only_if { ::File.exists? "/var/www/vhosts/#{package[:host]}/home/PackageInstaller" }
    end
  end

  if package[:packageInstaller]
    bash 'generate-behat-configuration' do
      user package[:user]
      group package[:user]
      cwd "/var/www/vhosts/#{package[:host]}/home/PackageInstaller"
      code <<-EOH
      php generate-behat-configuration.php --domain=http://#{package[:host]}/ \
          --database-password=#{node[:mysql][:users][package[:database]][:password]} \
          --database-user=#{package[:database]} \
          --database-name=#{package[:database]}
      EOH
      not_if { ::File.exists? "/var/www/vhosts/#{package[:host]}/home/PackageInstaller/behat.yml" }
    end
  end

  ##########################################
  # Reset script
  ##########################################

  if package[:packageName]
    template "/root/#{package[:host]}.reset.sh" do
      source "reset.sh"
      mode "0700"
      variables(
          :packageName => package[:packageName],
          :documentRoot => "/var/www/vhosts/#{package[:host]}/www",
          :host => package[:host],
          :database => package[:database],
          :password => node[:mysql][:users][package[:database]][:password],
          :user => package[:user]
      )
    end
  end

  # @todo add cron
  #cron "reset-demo" do
  #  hour "0,3,6,9,12,15,18,21"
  #  minute "0"
  #  command "/root/#{package[:host]}.reset.sh > /var/log/#{package[:host]}.log"
  #end
}

##########################################
# Main domain
##########################################
#template "/var/www/vhosts/demo.typo3.org/www/index.php" do
#  source "index.php"
#  mode "0700"
#  user "demotypo3org"
#  group "www-data"
#end
#
#template "/var/www/vhosts/demo.typo3.org/www/usage.html" do
#  source "usage.html"
#  mode "0700"
#  user "demotypo3org"
#  group "www-data"
#end
