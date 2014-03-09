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
include_recipe "php"
#include_recipe "php::apache2"

packages = [
  'php5-mysql',
  'php5-curl',
  'php5-gd',
  'php5-adodb',
  'php5-apc',
  'php5-mcrypt',
  'php5-sqlite',
  'php5-xsl',
  #'php5-mbstring',
  #'php5-openssl',
  #'php5-soap',
  'php5-ldap',
  'php5-suhosin',
  #'php5-posix',
  #'php5-iconv'
]

packages.each do |package|
  package package do
    action :install
  end
end


#template "/etc/php5/conf.d/suhosin.ini" do
#  source "suhosin.ini"
#  mode "0644"
#  notifies :restart, 'service[apache2]'
#end
