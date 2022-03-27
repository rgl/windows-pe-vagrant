Vagrant.configure('2') do |config|
  config.vm.box = 'windows-2022-amd64'

  config.vm.provider :libvirt do |lv, config|
    lv.memory = 4*1024
    lv.cpus = 4
    lv.cpu_mode = 'host-passthrough'
    #lv.nested = true
    lv.keymap = 'pt'
    config.vm.synced_folder '.', '/vagrant', type: 'smb', smb_username: ENV['USER'], smb_password: ENV['VAGRANT_SMB_PASSWORD']
  end

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.memory = 4*1024
    vb.cpus = 4
  end

  config.vm.provision :shell, inline: "$env:chocolateyVersion='1.0.1'; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))", name: "Install Chocolatey"
  config.vm.provision :shell, path: 'ps.ps1', args: 'provision-base.ps1'
  config.vm.provision :shell, path: 'ps.ps1', args: 'provision-adk.ps1'
  config.vm.provision :shell, path: 'ps.ps1', args: 'provision-winpe.ps1'
end
