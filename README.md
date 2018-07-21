# ayufan's Rock64 Linux releases

This repository contains a set of scripts to build ROCK64 linux images.

This is community maintained project in my free time. Don't expect everything to be perfect and working. Rather be prepared that there are problems, as always try to fix them and contribute, but if you can't drop the issue here so we can track the progress and resolution of the problem.

## Releases

You can always download [latest stable](https://github.com/ayufan-rock64/linux-build/releases/latest) release. The **releases** are meant to be stable versions.

If you want to test bleeding edge features use one of the [pre-releases](https://github.com/ayufan-rock64/linux-build/releases).
Use pre-releases only if you want to test bleeding edge features.

## Issues

If you have any problems with this build or any of the features do not work, feel free to create a new issue in this repository.

Please include information about the version you are using, a list of connected peripherials and any other details (logs) that can be helpful to understand the root cause of your problems.

## Contributing

Feel free to edit any of the files and send a PR to this repository or any in this organization.

## Components

It uses a bunch of different repositories:

- [kernel-rockchip](https://github.com/ayufan-rock64/linux-kernel) - patched Rockchip's kernel (4.4),
- [kernel-mainline](https://github.com/ayufan-rock64/linux-mainline-kernel) - patched mainline kernel (>= 4.13),
- [u-boot](https://github.com/ayufan-rock64/linux-u-boot) - patched mainline u-boot,
- [package](https://github.com/ayufan-rock64/linux-package) - scripts and configurations that improve Rock64 and RockPro64 experience,
- [rkbin](https://github.com/ayufan-rock64/rkbin) - precompiled bootloader binary blobs.

You can find latest pre-releases and releases of these components here:
- [kernel-rockchip](https://github.com/ayufan-rock64/linux-kernel/releases/latest) - patched Rockchip's kernel (4.4),
- [kernel-mainline](https://github.com/ayufan-rock64/linux-mainline-kernel/releases/latest) - patched mainline kernel (>= 4.13),
- [u-boot](https://github.com/ayufan-rock64/linux-u-boot/releases/latest) - patched mainline u-boot,
- [package](https://github.com/ayufan-rock64/linux-package/releases/latest) - scripts and configurations that improve Rock64 and RockPro64 experience,

Some of the packages are distributed via [PPA](https://launchpad.net/~ayufan/+archive/ubuntu/rock64-ppa/).
The sources of these packages are hosted in [this GitHub organization](https://github.com/ayufan-rock64).

This repository is regularly built by [Jenkins](https://jenkins.ayufan.eu/job/linux-build-rock-64/) and released in [Releases sections](https://github.com/ayufan-rock64/linux-build/releases).

## Documentation

For technical information, see the following documents:

- [release-contents.md](recipes/release-contents.md): Explains the contents of the linux image builds
- [compilation.md](recipes/release-contents.md): Explains the contents of the linux image builds
- [video-playback.md](recipes/video-playback.md): Explains how to get accelerated video playback
- [binfmt-misc.md](recipes/binfmt-misc.md): Run binaries from other architectures (ex: `arm64 on x86_64`)
- [configure-distcc.md](recipes/configure-distcc.md): Distribute compile jobs across multiple computers
- [dist-upgrade.md](recipes/dist-upgrade.md): Upgrade from an older build (ex: `0.5.x -> 0.6.x`)
- [dual-booting.md](recipes/dual-booting.md): Provides a menu to choose your OS/kernel at boot time
- [flash-spi.md](recipes/flash-spi.md): Flash the SPI memory to enable booting from USB or PXE
- [kernel-upgrade.md](recipes/kernel-upgrade.md): Upgrade your linux kernel to a newer version
- [additional-devices.md](recipes/additional-devices.md): Use additional devices, like 100Mbit Ethernet
- [overclocking.md](recipes/overclocking.md): Bump some specs :)
- [extlinux.md](recipes/extlinux.md): Make it easy to switch kernel versions
- [changing-boards.md](recipes/changing-boards.md): Switch existing installation between Rock64 and RockPro64 (highly experimental)

## License

These scripts are made available under the MIT license in the hope they might be useful to others. See LICENSE.txt for details.

## Author

Kamil Trzciński, 2017
