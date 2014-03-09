maintainer       "TYPO3 Association"
maintainer_email "fabien.udriot@typo3.org"
license          "Apache 2.0"
description      "Installs/Configures site-typo3org-mysql"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.2"

depends "database"
depends "mysql"
depends "php"
#depends "varnish"
depends "nginx"
#depends "apache2"
depends "iptables"
