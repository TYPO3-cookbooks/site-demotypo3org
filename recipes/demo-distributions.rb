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

distributions = [
  {
    :name => 'introduction',
    :domain => 'introduction.cms.demo.typo3.org',
    :type => 'cms',
    :directories => %w(log www)
  }, {
    :name => 'neos',
    :domain => 'neos.demo.typo3.org',
    :type => 'neos',
    :directories => %w(log shared releases/current/Web)
  }
]

distributions.each_with_index do |distribution, index|

  increment = index * 2

  # Double loop, first for public host, second for mater.
  stages = ["", "ms"]
  stages.each do |stage|

    # Local variable
    user = "#{stage}#{distribution[:name]}"
    database = user
    fpm_port = 9000 + increment
    host = "#{distribution[:domain]}"

    # True means, the stage is master
    if stage.length > 0
      host = "#{stage}." + host
      fpm_port = fpm_port + 1
    end

    ######################################
    # Create user and default directories
    ######################################

    user "#{user}" do
      comment 'User for demo.typo3.org Virtual Host'
      shell '/bin/bash'
    end

    distribution[:directories].each do |dir|
      directory "/var/www/vhosts/#{host}/#{dir}" do
        owner "#{user}"
        group "#{user}"
        mode '0755'
        recursive true
        action :create
      end
    end

    # Special case for Neos
    if distribution[:type] == 'neos'
      link "/var/www/vhosts/#{host}/www" do
        to "/var/www/vhosts/#{host}/releases/current/Web"
      end
    end

    ######################################
    # Nginx Configure Virtual Host
    ######################################

    template "nginx-#{host}" do
      path "#{node[:nginx][:dir]}/sites-available/#{host}"
      source "nginx-site-template.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :domain => "#{host}",
        :fpm_port => "#{fpm_port}"
      )
    end

    # True means, the stage is master
    nginx_action = :create
    if stage.length > 0
      nginx_action = :delete
    end

    link "#{node[:nginx][:dir]}/sites-enabled/#{host}" do
      to "#{node[:nginx][:dir]}/sites-available/#{host}"
      action nginx_action
      notifies :restart, 'service[nginx]'
    end

    ######################################
    # PHP FPM configuration
    ######################################

    template "php-fpm-#{host}" do
      path "/etc/php5/fpm/pool.d/#{host}.conf"
      source "php-fpm-site-template.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :domain => "#{host}",
        :user => "#{user}",
        :fpm_port => "#{fpm_port}",
        :pool_name => "#{host}".gsub(".", "")
      )
      notifies :restart, 'service[php5-fpm]'
    end

    ######################################
    # Configure database
    ######################################


    # Generate password and attach the info to the node
    ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
    node.set_unless[:mysql][:users][database][:password] = secure_password

    # Create DB + set User permission

    begin

      gem_package "mysql" do
        action :install
      end

      require 'mysql'
      m=Mysql.new("localhost", "root", node['mysql']['server_root_password'])

      if m.list_dbs.include?(database) == false

        # create database
        mysql_database "#{database}" do
          connection mysql_connection_info
          action :create
        end

        # create user
        mysql_database_user "#{database}" do
          connection mysql_connection_info
          password node[:mysql][:users][database][:password]
          action :create
        end

        # Grant user
        mysql_database_user "#{database}" do
          connection mysql_connection_info
          password node[:mysql][:users][database][:password]
          database_name database
          host '%'
          privileges [:select, :update, :insert, :alter, :index, :create, :drop, :delete]
          action :grant
        end
      end
    rescue LoadError
      Chef::Log.info("Missing gem 'mysql'")
    end

    ##########################################
    # Reset script
    ##########################################

    # true means mater
    if stage.length == 0
      template_source = "reset-#{distribution[:type]}.sh"
      database_master = "ms#{database}"
      password_master = node[:mysql][:users][database_master][:password]
    else
      template_source = "reset-#{distribution[:type]}-ms.sh"
      password_master = ""
    end

    template "/root/#{host}.reset.sh" do
      source template_source
      mode "0700"
      variables(
        :distribution_name => distribution[:name],
        :document_root => "/var/www/vhosts/#{host}/www",
        :host => host,
        :database => database,
        :password => node[:mysql][:users][database][:password],
        :password_master => password_master,
        :password_root => node['mysql']['server_root_password'],
        :user => user
      )
    end

    # Only for non master
    if stage.length == 0
      cron "reset-demo-#{host}" do
        minute increment
        command "/root/#{host}.reset.sh > /var/log/#{host}.log"
      end
    end

  end # foreach stages

end # foreach distribution

##########################################
# Add hook preventing website defacement
##########################################

template "/root/AdditionalConfiguration.php" do
  source "typo3-additional-configuration.php"
  mode "0700"
end

template "/root/403.html" do
  source "403.html"
  mode "0700"
end
