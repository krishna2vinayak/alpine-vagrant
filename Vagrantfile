Vagrant.configure(2) do |config|
  config.vm.box = 'alpine-3.16-amd64'
  #config.vm.box = 'alpine-3.16-uefi-amd64'

  config.vm.hostname = 'example.test'
  config.vm.provider 'virtualbox' do |vb|
    vb.linked_clone = true
    vb.memory = 4*1024
    vb.cpus = 4
  end
end
