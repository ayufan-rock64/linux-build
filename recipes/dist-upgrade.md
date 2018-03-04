# Distribution upgrading

[ayufan's](https://github.com/ayufan-rock64/linux-build/releases) builds are released quite frequently.

Upgrading to the latest greatest (and experimental) releases is quite simple:

1. Uncomment pre-releases from `/etc/apt/sources.list.d/ayufan-rock64.list`
2. Perform dist-upgrade:

    ```bash
    apt-get update
    apt-get dist-upgrade
    ```

3. Reboot
