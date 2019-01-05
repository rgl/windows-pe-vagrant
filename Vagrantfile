Vagrant.configure('2') do |config|
  config.vm.box = 'windows-2016-amd64'

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.memory = 2048
  end

  config.vm.provision :shell, inline: "$env:chocolateyVersion='0.10.11'; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex", name: "Install Chocolatey"
  config.vm.provision :shell, path: 'ps.ps1', args: 'provision-winpe.ps1'
end
