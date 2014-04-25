#
# Cookbook Name:: site-demotypo3org
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

# Library
include_recipe "site-demotypo3org::base"
include_recipe "site-demotypo3org::iptables"
include_recipe "site-demotypo3org::mysql"
include_recipe "site-demotypo3org::php5"
include_recipe "site-demotypo3org::php5-fpm"
include_recipe "site-demotypo3org::nginx"

include_recipe "site-demotypo3org::demo-landing-page"
include_recipe "site-demotypo3org::demo-distributions"
include_recipe "site-demotypo3org::demo-monitoring"
