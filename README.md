An example [Windows PE (WinPE)](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro) iso built in a vagrant environment.

# Usage

Install the [Windows 2025 UEFI Base Box](https://github.com/rgl/windows-vagrant).

Build the ISO with:

```bash
vagrant up --no-destroy-on-error --no-tty build | tee build.log
```

When it finishes, you should have the ISO in the `tmp/winpe-amd64.iso` file.

The ISO file can be written to an usb disk or [pxe booted](https://github.com/rgl/pxe-vagrant).

You can also try it with:

```bash
vagrant up --no-destroy-on-error --no-tty winpe
```

Switch the Windows PE VM Console.

Start the `Windows Task Manager`, so we can later start other applications by
using the `New Task...` button:

```powershell
taskmgr
```

Try getting a file from the `test` S3 bucket (hosted in the `build` VM):

**NB** The IP address bellow belongs to the `build` VM.

```powershell
Invoke-RestMethod http://10.9.9.2:9000/test/index.html
```

Mount the `test` S3 bucket:

```powershell
$env:AWS_ACCESS_KEY_ID     = 'winpe'
$env:AWS_SECRET_ACCESS_KEY = 'password'
# NB this can also mount over an existing directory (it automatically manages
#    the mount sub-directory). e.g. c:\s3fs-test.
# NB to debug include:
#       --debug -o dbglevel=debug -o curldbg
&"X:\Program Files\s3fs-fuse\s3fs.exe" `
    test `
    a: `
    -f `
    -o url=http://10.9.9.2:9000 `
    -o tmpdir=x:/windows/temp `
    -o use_path_request_style `
    -o ro `
    -o umask=222 `
    -o compat_dir=1 `
    -o complement_stat=1
```

Using `Windows Task Manager`, start a `cmd` shell, and then list the files
inside the `test` S3 bucket:

```batch
dir a:
type a:\index.html
```

# Reference

* [Windows PE (WinPE)](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-intro)
* [WinPE: Mount and Customize](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize)
* [WinPE: Create Apps](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-apps)
