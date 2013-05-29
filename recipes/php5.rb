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

template "/etc/php5/conf.d/suhosin.ini" do
  source "suhosin.ini"
  mode "0644"
  notifies :restart, 'service[apache2]'
end

# install apc pecl with directives
#php_pear "apc" do
#  action :install
#  directives(:shm_size => 128, :enable_cli => 1)
#end


#echo"apc.enabled = 1
#apc.shm_size = 128
#apc.shm_segments=1
#apc.write_lock = 1
#apc.rfc1867 = On
#apc.ttl=7200
#apc.user_ttl=7200
#apc.num_files_hint=1024
#apc.mmap_file_mask=/tmp/apc.XXXXXX
#apc.enable_cli=1
#apc.slam_defense = Off
