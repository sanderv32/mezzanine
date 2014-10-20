# -*- mode: ruby -*-
# vi: set ts=2 sw=8 tw=0 et ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "Centos-Sanoma"
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/snm-nl-hostingsupport-test/vagrant-centos-6-4.box"
  config.vm.hostname = "sanoma.local"

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "deploy/manifests"
    puppet.manifest_file  = "site.pp"
    puppet.module_path = "deploy/modules"
    #puppet.options = "--verbose --debug"
  end
end
