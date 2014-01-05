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

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

packages = [
  {
    :user => 'demotypo3org',
    :host => 'neos.demo.typo3.org',
    :distributionName => 'neos',
    :database => 'neos',
    :packageInstaller => 'https://github.com/TYPO3/PackageInstaller.git',
    :cronMinute => 06,
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

  %w{home log releases shared current current/Web}.each do |dir|
    directory "/var/www/vhosts/#{package[:host]}/#{dir}" do
      owner package[:user]
      group 'root'
      mode '0755'
      recursive true
      action :create
    end
  end

  link "/var/www/vhosts/#{package[:host]}/www" do
    to "/var/www/vhosts/#{package[:host]}/releases/current/Web"
  end

  ######################################
  # Configure Virtual Host
  ######################################

  template "#{package[:host]}" do
    path "#{node[:apache][:dir]}/sites-available/#{package[:host]}"
    source 'apache2-site-template.erb'
    owner node[:apache][:user]
    group node[:apache][:group]
    mode 0644
    variables(
      :log_dir => "/var/www/vhosts/#{package[:host]}/log",
      :document_root => "/var/www/vhosts/#{package[:host]}/www",
      :server_name => "#{package[:host]}",
      :environment_variable => "SetEnv FLOW_CONTEXT Production"
    )
  end

  # Enable virtual host
  apache_site "#{package[:host]}" do
    enable true
    notifies :restart, 'service[apache2]'
  end

  ######################################
  # Configure database
  ######################################


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

  ######################################
  # Configuration package installer
  ######################################

  bash 'clone-package-installer' do
    user package[:user]
    group package[:user]
    cwd "/var/www/vhosts/#{package[:host]}/home"
    code <<-EOH
      git clone #{package[:packageInstaller]}
    EOH
    not_if { ::File.exists? "/var/www/vhosts/#{package[:host]}/home/PackageInstaller" }
  end

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

  bash 'generate-behat-configuration' do
    user package[:user]
    group package[:user]
    cwd "/var/www/vhosts/#{package[:host]}/home/PackageInstaller"
    code <<-EOH
      php generate-behat-configuration.php --domain=http://#{package[:host]}/ \
          --database-password=#{node[:mysql][:users][package[:database]][:password]} \
          --database-user=#{package[:database]} \
          --database-name=#{package[:database]} \
          --neos
    EOH
    not_if { ::File.exists? "/var/www/vhosts/#{package[:host]}/home/PackageInstaller/behat.yml" }
  end

  ##########################################
  # Reset script
  ##########################################

  template "/root/#{package[:host]}.reset.sh" do
    source "reset-neos.sh"
    mode "0700"
    variables(
      :distributionName => package[:distributionName],
      :documentRoot => "/var/www/vhosts/#{package[:host]}/www",
      :currentRelease => "/var/www/vhosts/#{package[:host]}/releases/current",
      :host => package[:host],
      :database => package[:database],
      :password => node['mysql']['server_root_password'],
      :user => package[:user]
    )
  end

  cron "reset-demo-#{package[:host]}" do
    #hour '2,5,8,11,14,17,20,23'
    minute package[:cronMinute]
    command "/root/#{package[:host]}.reset.sh > /var/log/#{package[:host]}.log"
  end
}

##########################################
# Add hook preventing website defacement
##########################################

template "/root/403.html" do
  source "403.html"
  mode "0700"
end

template "/etc/init.d/phantomjs" do
  source "phantomjs.sh"
  mode "0755"
end