# -*- mode: ruby -*-
# vi: set ft=ruby :
sVUSER='vagrant'  # // vagrant user
sHOME="/home/#{sVUSER}"  # // home path for vagrant user
sNET='en0: Wi-Fi (Wireless)'  # // network adaptor to use for bridged mode

Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024  # // RAM / Memory
    v.cpus = 1  # // CPU Cores / Threads
  end

  config.vm.define "vault-dev"
  config.vm.hostname = "vault-dev"
  config.vm.network "public_network", bridge: "#{sNET}"
  # // four (4x) example / demonstration files:
  config.vm.provision "file", source: "vault_example_app.sh", destination: "#{sHOME}/"
  config.vm.provision "file", source: "vault_example_file.sh", destination: "#{sHOME}/"
  config.vm.provision "file", source: "vault_example_file.template", destination: "#{sHOME}/"
  config.vm.provision "file", source: "vault_run_examples.sh", destination: "#{sHOME}/"
  # // -----------------------------------------
  # // installers:
  config.vm.provision "shell", path: "1.install_commons.sh"
  config.vm.provision "file", source: "2.install_vault.sh", destination: "#{sHOME}/install_vault.sh"
  config.vm.provision "shell", inline: "/bin/bash -c '#{sHOME}/install_vault.sh'"
  config.vm.provision "file", source: "3.install_envconsul+consul-template.sh", destination: "#{sHOME}/install_envconsul+consul-template.sh"
  config.vm.provision "shell", inline: "/bin/bash -c '#{sHOME}/install_envconsul+consul-template.sh'"
end
