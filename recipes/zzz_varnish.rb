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

######################################
# Install Varnish
######################################
include_recipe "varnish"


template "/etc/varnish/default.vcl" do
  path "/etc/varnish/default.vcl"
  source "typo3-minimal.vcl.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'service[varnish]'
end


template "/etc/default/varnish" do
  path "/etc/default/varnish"
  source "varnish.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'service[varnish]'
end
