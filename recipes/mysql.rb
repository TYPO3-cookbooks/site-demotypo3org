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


####################################################
# Install MySQL server and create databases
####################################################
include_recipe "mysql::server"
include_recipe "mysql::client"
include_recipe "database"

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

%w{masterdemot3org demot3org}.each do |db|

  # Generate password and attach the info to the node
  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
  node.set_unless[:mysql][:users]["#{db}"][:password] = secure_password

  # Create DB + set User permission
  begin
    gem_package "mysql" do
      action :install
    end
    Gem.clear_paths
    require 'mysql'
    m=Mysql.new("localhost","root",node['mysql']['server_root_password'])

    if m.list_dbs.include?("#{db}") == false
      # create database
      mysql_database "#{db}" do
        connection mysql_connection_info
        action :create
      end

      # create user
      mysql_database_user "#{db}" do
        connection mysql_connection_info
        password node[:mysql][:users]["#{db}"][:password]
        action :create
      end

      # Grant user
      mysql_database_user "#{db}" do
        connection mysql_connection_info
        password node[:mysql][:users]["#{db}"][:password]
        database_name "#{db}"
        host '%'
        privileges [:select,:update,:insert,:alter,:index,:create,:drop,:delete]
        action :grant
      end
    end
  rescue LoadError
    Chef::Log.info("Missing gem 'mysql'")
  end
end
