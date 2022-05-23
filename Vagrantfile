ENV['VAGRANT_NO_PARALLEL'] = 'yes'

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

  config.vm.define :build do |config|
    config.vm.provision :shell, inline: "$env:chocolateyVersion='1.1.0'; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))", name: "Install Chocolatey"
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-base.ps1'
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-adk.ps1'
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-winpe.ps1'
  end

  [
    'bios',
    'uefi',
  ].each do |firmware|
    config.vm.define firmware do |config|
      config.vm.box = nil
      config.vm.provider :libvirt do |lv, config|
        lv.loader = '/usr/share/ovmf/OVMF.fd' if firmware == 'uefi'
        lv.boot 'hd'
        lv.boot 'cdrom'
        lv.storage :file, :size => '40G'
        lv.storage :file, :device => :cdrom, :bus => 'sata', :path => "#{Dir.getwd}/tmp/winpe-amd64.iso"
        lv.mgmt_attach = false
        lv.machine_type = 'q35'
        lv.cpu_mode = 'host-passthrough'
        lv.graphics_type = 'spice'
        lv.video_type = 'qxl'
        lv.input :type => 'tablet', :bus => 'virtio'
        lv.channel :type => 'unix', :target_name => 'org.qemu.guest_agent.0', :target_type => 'virtio'
        lv.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
        config.vm.synced_folder '.', '/vagrant', disabled: true
      end
    end
  end
end
