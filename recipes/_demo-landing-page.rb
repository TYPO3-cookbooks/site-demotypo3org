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
    :fpm_port => 8999,
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
  # PHP FPM configuration
  ######################################

  template "php-fpm-#{package[:host]}" do
    path "/etc/php5/fpm/pool.d/#{package[:host]}.conf"
    source "php-fpm-site-template.erb"
    owner "root"
    group "root"
    mode 0644
    pool_name = "#{package[:host]}".gsub(".", "")
    variables(
      :domain => "#{package[:host]}",
      :user => "#{package[:user]}",
      :fpm_port => "#{package[:fpm_port]}",
      :pool_name => "#{pool_name}"
    )
    notifies :restart, 'service[php5-fpm]'
  end

  ######################################
  # Nginx Configure Virtual Host
  ######################################

  template "nginx-#{package[:host]}" do
    path "#{node[:nginx][:dir]}/sites-available/#{package[:host]}"
    source "nginx-site-template.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :domain => "#{package[:host]}",
      :fpm_port => "#{package[:fpm_port]}"
    )
  end

  link "#{node[:nginx][:dir]}/sites-enabled/#{package[:host]}" do
    to "#{node[:nginx][:dir]}/sites-available/#{package[:host]}"
    notifies :restart, 'service[nginx]'
  end

}

##########################################
# Clone landing page
##########################################

git "/var/www/vhosts/demo.typo3.org/www" do
  repository "git://git.typo3.org/Sites/DemoTypo3Org.git"
  action :sync
  enable_submodules true
  user 'demotypo3org'
  group 'www-data'
end
