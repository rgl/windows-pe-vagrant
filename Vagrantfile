ENV['VAGRANT_NO_PARALLEL'] = 'yes'

# the network prefix we use in this environment.
# NB this must be a /24 prefixed network.
$network_address_prefix = '10.9.9'
$public_bridge_name = nil

# configure the virtual machines network to use an already configured bridge.
# NB this is used for connecting to the external world (alike the one
#    described at https://github.com/rgl/pxe-raspberrypi-vagrant).
# NB set to nil to for using private networking.
#$network_address_prefix = '10.7.0'
#$public_bridge_name = 'br-rpi'

Vagrant.configure('2') do |config|
  config.vm.box = 'windows-2025-uefi-amd64'

  config.vm.provider :libvirt do |lv, config|
    lv.memory = 4*1024
    lv.cpus = 4
    lv.cpu_mode = 'host-passthrough'
    #lv.nested = true
    lv.keymap = 'pt'
    config.vm.synced_folder '.', '/vagrant', type: 'smb', smb_username: ENV['USER'], smb_password: ENV['VAGRANT_SMB_PASSWORD']
  end

  config.vm.define :build do |config|
    if $public_bridge_name
      config.vm.network :public_network,
        dev: $public_bridge_name,
        mode: 'bridge',
        type: 'bridge',
        mac: '080027000000',
        ip: "#{$network_address_prefix}.2"
    else
      config.vm.network :private_network,
        mac: '080027000000',
        ip: "#{$network_address_prefix}.2",
        libvirt__dhcp_enabled: true,
        libvirt__forward_mode: 'nat'
    end
    config.vm.provision :shell, inline: "$env:chocolateyVersion='2.7.3'; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))", name: "Install Chocolatey"
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-base.ps1'
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-adk.ps1'
    config.vm.provision :shell, path: 'ps.ps1', args: 'provision-winpe.ps1'
  end

  config.vm.define :winpe do |config|
    config.vm.box = nil
    if $public_bridge_name
      config.vm.network :public_network,
        dev: $public_bridge_name,
        mode: 'bridge',
        type: 'bridge',
        mac: "080027000001",
        ip: "#{$network_address_prefix}.0",
        auto_config: false
    else
      config.vm.network :private_network,
        mac: "080027000001",
        ip: "#{$network_address_prefix}.0",
        auto_config: false
    end
    config.vm.provider :libvirt do |lv, config|
      lv.loader = '/usr/share/ovmf/OVMF.fd'
      lv.cpu_mode = "host-passthrough"
      lv.features = ["acpi", "apic", "hyperv mode='passthrough'", "vmport state='off'"]
      lv.clock_offset = 'localtime'
      lv.clock_timer :name => 'rtc', :tickpolicy => 'catchup'
      lv.clock_timer :name => 'pit', :tickpolicy => 'delay'
      lv.clock_timer :name => 'hpet', :present => 'no'
      lv.clock_timer :name => 'hypervclock', :present => 'yes'
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
