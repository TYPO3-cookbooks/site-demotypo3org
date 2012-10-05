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

######################################
# Create demo.typo3.org User
######################################
user "demotypo3org" do
  comment "User for demo.typo3.org Virtual Host"
  shell "/bin/bash"
end

%w{home log www core}.each do |dir|
  directory "/var/www/vhosts/demo.typo3.org/#{dir}" do
    owner "demotypo3org"
    group "root"
    mode "0755"
    recursive true
    action :create
  end
end

######################################
# Create master.demo.typo3.org User
######################################
user "masterdemotypo3org" do
  comment "User for master.demo.typo3.org Virtual Host"
  shell "/bin/bash"
end

%w{home log www core}.each do |dir|
  directory "/var/www/vhosts/master.demo.typo3.org/#{dir}" do
    owner "masterdemotypo3org"
    group "root"
    mode "0755"
    recursive true
    action :create
  end
end
