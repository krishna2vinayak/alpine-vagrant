Vagrant.configure(2) do |config|
  config.ssh.shell = '/bin/ash'
  config.ssh.sudo_command = 'doas %c'
  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--firmware', 'efi']
    vb.customize ["modifyvm", :id, "--paravirtprovider", "minimal"]
    vb.customize ["modifyvm", :id, "--vrde", "off"]
  end
end
