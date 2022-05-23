An example [Windows PE (WinPE)](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro) iso built in a vagrant environment.

# Usage

Install the [Windows 2022 Base Box](https://github.com/rgl/windows-vagrant).

Build the ISO with:

```bash
vagrant up --no-destroy-on-error --no-tty build
```

When it finishes, you should have the ISO in the `tmp/winpe-amd64.iso` file.

The ISO file can be written to an usb disk or [pxe booted](https://github.com/rgl/pxe-vagrant).

You can also try it with:

```bash
vagrant up --no-destroy-on-error --no-tty bios
vagrant up --no-destroy-on-error --no-tty uefi
```

# Reference

* [Windows PE (WinPE)](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro)
* [WinPE: Mount and Customize](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize)
* [WinPE: Create Apps](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-apps)
