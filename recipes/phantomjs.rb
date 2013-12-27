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

# Create new user
user "phantomjs" do
  comment 'User for PhantomJS daemon'
  shell '/bin/bash'
end

# Create log directory
directory "/var/log/phantomjs" do
  owner 'phantomjs'
  group 'phantomjs'
  mode '0755'
  recursive true
  action :create
end

# Install PhantomJS
bash 'install-phantomjs-binary' do
  #user package[:user]
  #group package[:user]
  cwd "/tmp"
  code <<-EOH
    wget https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2
    tar -xjvf phantomjs-1.9.2-linux-x86_64.tar.bz2
    mv phantomjs-1.9.2-linux-x86_64 /usr/local/phantomjs
    chmod 755 /usr/local/phantomjs/bin/phantomjs
  EOH
  not_if { ::File.exists? "/usr/local/phantomjs/bin/phantomjs" }
end


# @todo
# Check if service is running, if not -> "service phantomjs start"

