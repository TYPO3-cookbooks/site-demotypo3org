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

# Configure Virtual Host
## @todo remove VH masterdemotypo3org + database demotypo3org mastertypo3org
#include_recipe "site-demotypo3org::iptables"
#include_recipe "site-demotypo3org::imagemagick"
#include_recipe "site-demotypo3org::mysql"
include_recipe "site-demotypo3org::php5"
##include_recipe "site-demotypo3org::apache2"
#include_recipe "site-demotypo3org::phantomjs"
#
## Varnish introduces a cache effect that would imply a special TYPO3 extension to deal with.
#include_recipe "site-demotypo3org::php5-fpm"
##include_recipe "site-demotypo3org::nginx"
#include_recipe "site-demotypo3org::varnish"
#
#include_recipe "site-demotypo3org::demo-landing-page"
#include_recipe "site-demotypo3org::demo-typo3cms-distributions"
#include_recipe "site-demotypo3org::demo-neos-distributions"
