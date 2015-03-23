name "site-demotypo3org"
maintainer       "TYPO3 Association"
maintainer_email "fabien.udriot@typo3.org"
license          "Apache 2.0"
description      "Installs/Configures site-typo3org-mysql"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.5.4"

depends "database", "~> 1.3.0"
depends "mysql", "~> 1.3.0"
depends "php", "~> 1.1.0"
depends "nginx", "~> 1.6.0"
depends "iptables", "~> 0.9.0"
depends "composer", '~> 1.1.0'
