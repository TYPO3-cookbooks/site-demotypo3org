#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2012, Fabien Udriot <fabien@omic.ch>
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

include_recipe "iptables"

#iptables_rule "iptables-rules"


######################################
# Reset firewall
######################################
script "reset-iptables" do
  interpreter "bash"
  user "root"
  code <<-EOF
iptables -P INPUT ACCEPT; iptables -P OUTPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -F; iptables -X

# Setting default filter policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow unlimited traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming ssh
iptables -A INPUT -p tcp  --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# Allow incoming www
iptables -A INPUT -p tcp  --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT

# Allow outgoing www
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -j ACCEPT

# Allow outgoing https
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT

# Allow outgoing DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

# Allow incoming Mosh traffic
iptables -A INPUT -p udp --dport 60000:60010 -j ACCEPT
iptables -A OUTPUT -p udp --sport 60000:60010 -j ACCEPT

# Allow outoing 4000 (Chef)
iptables -A OUTPUT -p tcp --dport 4000 -j ACCEPT
iptables -A INPUT -p tcp --sport 4000 -j ACCEPT

# Allow outoing 10051 (Zabbix)
iptables -A OUTPUT -p tcp --dport 10051 -j ACCEPT
iptables -A INPUT -p tcp --sport 10051 -j ACCEPT

# Allow outoing 9418 (Git)
iptables -A OUTPUT -p tcp --dport 9418 -j ACCEPT
iptables -A INPUT -p tcp --sport 9418 -j ACCEPT

# make sure nothing comes or goes out of this box
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

EOF
end
