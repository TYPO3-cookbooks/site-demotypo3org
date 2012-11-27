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
# DEPLOY INTRODUCTION PACKAGE
######################################
script "install-typo3-core" do
  interpreter "bash"
  user "masterdemotypo3org"
  code <<-EOH

  home="/var/www/vhosts/master.demo.typo3.org"

  if [ ! -f $home/www/index.php ];
  then

    echo 'Deploying introduction package...'
    cd $home/home

    # Check the validity of the version
    wget http://get.typo3.org/introduction -O introduction-package.tar.gz
    tar -xzf introduction-package.tar.gz
    rm introduction-package.tar.gz
    mv introduction* introduction-package
    mv introduction-package/* introduction-package/.htaccess ../www/
    rm -rf introduction*

    cd $home/www
    rm -rf typo3_src-6.0.0 typo3_src
    ln -s ../core/typo3_src.git typo3_src
    chmod -R 777 typo3temp typo3conf fileadmin uploads
  fi

  if [ ! -f $home/core/typo3_src.git ];
  then
    cd $home/core
    git clone --recursive git://git.typo3.org/TYPO3v4/Core.git typo3_src.git
    cd $home/core/typo3_src.git
    git checkout -b TYPO3_6-0 --track origin/TYPO3_6-0
    git submodule update
  fi

EOH
end

script "update-repository" do
  interpreter "bash"
  user "masterdemotypo3org"
  code <<-EOF
    cd /var/www/vhosts/master.demo.typo3.org/core/typo3_src.git
    git pull
    git submodule update
  EOF
end

######################################
# GENERATE SCRIPT THAT RETURNS TIME
######################################


file "/var/www/vhosts/master.demo.typo3.org/www/time.php" do

  owner "root"
  group "root"
  mode "0755"
  action :create
  content <<-EOF
<?php
date_default_timezone_set("UTC");
echo date("c");
?>
EOF
end

######################################
# GENERATE RESET SCRIPT
######################################
file "/root/reset-demo.sh" do

  owner "root"
  group "root"
  mode "0755"
  action :create
  content <<-EOF
#!/bin/sh
source="/var/www/vhosts/master.demo.typo3.org"
target="/var/www/vhosts/demo.typo3.org"

cd /tmp
echo 'Rebuild database...'
mysql -u root -p#{node['mysql']['server_root_password']} -e "DROP DATABASE demot3org; CREATE DATABASE demot3org"
mysqldump -u root -p#{node['mysql']['server_root_password']} masterdemot3org > /tmp/masterdemot3org.sql
mysql -u root -p#{node['mysql']['server_root_password']} demot3org < /tmp/masterdemot3org.sql
mysql -u root -p#{node['mysql']['server_root_password']} -e "UPDATE sys_domain SET domainName = REPLACE(domainName, 'master.demo.typo3.org', 'demo.typo3.org');" demot3org

echo 'Remove LocalConfiguration files that should not be synched...'
rm -f $source/www/typo3conf/LocalConfiguration.php
rm -f $target/www/typo3conf/LocalConfiguration.php

echo 'Sync files...'
rsync -qaEP --delete $source/core/ $target/core/
rsync -qaEP --delete $source/www/ $target/www/

echo 'Restore LocalConfiguration files...'
cp  /root/localconf.master.demo.typo3.org.php $source/www/typo3conf/LocalConfiguration.php
cp  /root/localconf.demo.typo3.org.php $target/www/typo3conf/LocalConfiguration.php

echo 'Set permissions...'
chmod -R 755 $target/www/fileadmin/ $target/www/typo3conf/ $target/www/uploads/
chown -R root:root $target/www $target/core

#echo 'Update LocalConfiguration...'
#cd $target/www/typo3conf
#sed -i 's/masterdemot3org/demot3org/g' LocalConfiguration.php
#sed -i 's/#{node[:mysql][:users][:masterdemot3org][:password]}/#{node[:mysql][:users][:demot3org][:password]}/g' LocalConfiguration.php

echo 'Remove temp files...'
rm -f $source/www/typo3conf/temp*
rm -f $target/www/typo3conf/temp*

echo 'Disable master virtual host...'
#rm -f /etc/nginx/sites-enabled/master.demo.typo3.org
#service nginx reload

rm -f /etc/apache2/sites-enabled/master.demo.typo3.org
service apache2 reload
EOF

end


##########################################
# Poor man's monitoring
##########################################

template "/root/check-demo.sh" do
  source "check-demo.sh"
  mode "0755"
end

cron "check-demo" do
  minute "*"
  command "/root/check-demo.sh > /dev/null"
end

##########################################
# Website list
##########################################
websites = %w{master.demo.typo3.org demo.typo3.org}

# Write virtual host files and enable symlink
websites.each_with_index do |host, index|

  # Nginx virtual host configuration
  template "localconf-#{host}" do
    path "/root/localconf.#{host}.php"
    source "typo3-localconf.erb"
    owner "root"
    group "root"
    mode 0644

    if host == 'demo.typo3.org'
      username = "demot3org"
      database = "demot3org"
      password = "#{node[:mysql][:users][:demot3org][:password]}"
    else
      username = "masterdemot3org"
      database = "masterdemot3org"
      password = "#{node[:mysql][:users][:masterdemot3org][:password]}"
    end

    variables(
      :username => "#{username}",
      :password => "#{password}",
      :database => "#{database}"
    )
  end

end

######################################
# GENERATE ENABLE MASTER SCRIPT
######################################

# By default master is disabled. Just write a convenience script that will re-enable whenever invoked from the CLI.
file "/root/enable-master.sh" do

  owner "root"
  group "root"
  mode "0755"
  action :create
  content <<-EOF

#!/bin/sh

#ln -s /etc/nginx/sites-available/master.demo.typo3.org /etc/nginx/sites-enabled/master.demo.typo3.org
#service nginx reload

ln -s /etc/apache2/sites-available/master.demo.typo3.org /etc/apache2/sites-enabled/master.demo.typo3.org
service apache2 reload
EOF

end

######################################
# SCHEDULE RESET SCRIPT
######################################
cron "reset-demo" do
  hour "0,3,6,9,12,15,18,21"
  minute "0"
  command "/root/reset-demo.sh > /root/reset-demo.log"
end

