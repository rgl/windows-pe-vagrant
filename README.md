An example [Windows PE (WinPE)](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro) iso built in a vagrant environment.

# Usage

Install the [Windows 2022 Base Box](https://github.com/rgl/windows-vagrant).

Then start this environment:

```bash
vagrant up
```

When it finishes, you should have a `tmp/winpe-amd64.iso` file.

The `iso` file can be written to an usb disk or [pxe booted](https://github.com/rgl/pxe-vagrant).

# Reference

* [Windows PE (WinPE)](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro)
* [WinPE: Mount and Customize](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize)
* [WinPE: Create Apps](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-apps)
