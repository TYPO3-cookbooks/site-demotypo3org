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

websites = [
  {
    :user => 'demotypo3org',
    :host => 'demo.typo3.org',
  }
]

websites.each { |package|

  ######################################
  # Create user and default directories
  ######################################

  user "#{package[:user]}" do
    comment 'User for demo.typo3.org Virtual Host'
    shell '/bin/bash'
  end

  %w{home log www}.each do |dir|
    directory "/var/www/vhosts/#{package[:host]}/#{dir}" do
      owner package[:user]
      group 'root'
      mode '0755'
      recursive true
      action :create
    end
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
      :server_name => "#{package[:host]}"
    )
  end

  # Enable virtual host
  apache_site "#{package[:host]}" do
    enable true
    notifies :restart, 'service[apache2]'
  end
}


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
