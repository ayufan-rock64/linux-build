# Distribution upgrading

[ayufan's](https://github.com/ayufan-rock64/linux-build/releases) builds are released quite frequently.

Upgrading to the latest greatest (and experimental) releases is quite simple:

1. Uncomment pre-releases from `/etc/apt/sources.list.d/ayufan-rock64.list`
2. Perform dist-upgrade:

    ```bash
    sudo apt-get update
    sudo apt-get dist-upgrade
    ```

3. If you are running a desktop environment or X11 setup, see the below note on X11.

4. Reboot

## X11 and older releases

When upgrading from older releases, some users have reported issues with X11 no longer starting. If you are upgrading an older (i.e. `0.5.x`) release with a desktop environment, before rebooting the system it is advisable that you run the following command: 

```bash
sudo apt-get install xserver-xorg-video-armsoc
```

You may also want to check the contents of the `/etc/X11/xorg.conf.d/` directory, and if `20-modesetting.conf` is present, move or rename it. i.e. `sudo mv /etc/X11/xorg.conf.d/20-modesetting.conf /etc/X11/xorg.conf.d/20-modesetting.disabled` 

If you don't do this, there is a chance that X11 will crash on next boot, and you'll need to login to your system using a serial console or via SSH, and run the above commands. You should then be able to reboot your system and be greeted with a working X11 install again!
