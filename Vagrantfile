# -*- mode: ruby -*-
# vi: set ft=ruby :

box = {
  :name => 'demo.typo3.box',
  :ip => '192.168.188.188'
}

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

##################################################
# Check environment
##################################################

Vagrant.require_version ">= 1.5.0"

unless Vagrant.has_plugin?("vagrant-cachier")
  raise 'Missing plugin! Install with `vagrant plugin install vagrant-cachier`'
end

unless Vagrant.has_plugin?("vagrant-omnibus")
  raise 'Missing plugin! Install with `vagrant plugin install vagrant-omnibus`'
end

unless Vagrant.has_plugin?("vagrant-berkshelf")
  raise 'Missing plugin! Install with `vagrant plugin install vagrant-berkshelf`'
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = box[:name]

  # Set the version of chef to install using the vagrant-omnibus plugin
  config.omnibus.chef_version = :latest

  # Every Vagrant virtual environment requires a box to build off of.
  # If this value is a shorthand to a box in Vagrant Cloud then
  # config.vm.box_url doesn't need to be specified.
  #config.vm.box = "chef/ubuntu-14.04"
  config.vm.box = ENV['VAGRANT_BOX'] || "chef/debian-7.6"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: box[:ip]

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  #########################
  # Shared folders
  #########################

  # Disable default shared folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    #   # Don't boot with headless mode
    #   vb.gui = true
    #
    #   # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end


  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.provision :chef_solo do |chef|

    chef.custom_config_path = "Vagrantfile.chef"
    chef.log_level = ENV['CHEF_LOG_LEVEL'] || :info

    chef.json = {
      mysql: {
        server_root_password: 'root',
        server_debian_password: 'root',
        server_repl_password: 'root'
      },

      # Override default configuration for the application
      # "site-builddocstypo3org" => {
      #   app: {
      #     context: 'Development/Vagrant',
      #     server_alias: 'build.docs.typo3.dev build.docs.typo3.local'
      #   },
      #   install: {
      #     libreoffice: false, # "true" whether you want conversion of legacy manual.sxw conversion. Takes time to download...
      #     texlive: false, # "true" whether you want PDF generation. Takes time to download...
      #     cron: false
      #   }
      #}
    }

    chef.run_list = [
      "recipe[site-demotypo3org::default]"
    ]
  end
end
