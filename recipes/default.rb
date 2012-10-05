#
# Cookbook Name:: site-demo
# Recipe:: default
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

# Configure Virtual Host
include_recipe "site-demo::base"
include_recipe "site-demo::iptables"
include_recipe "site-demo::imagemagick"
include_recipe "site-demo::mysql"
include_recipe "site-demo::php5"

# Varnish introduces a cache effect that would imply a special TYPO3 extension to deal with.
#include_recipe "site-demo::php5-fpm"
#include_recipe "site-demo::nginx"
#include_recipe "site-demo::varnish"

include_recipe "site-demo::apache2"
include_recipe "site-demo::introduction-package"
