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
# Install PHP and PHP-FPM (FastCGI Process Manager)
##########################################


include_recipe "php"
include_recipe "php::fpm"

packages = [
  'php5-fpm'
]

case node[:platform]
  when "debian", "ubuntu"
    packages.each do |pkg|
      package pkg do
        action :upgrade
    end
  end
  when "centos"
    log "No centos support yet"
end

# Delete default config
file "/etc/php5/fpm/pool.d/www.conf" do
  action :delete
  notifies  :restart, 'service[php5-fpm]'
end

# start up php-fpm
service "php5-fpm" do
  supports :restart => true
  action [ :enable, :start ]
end
