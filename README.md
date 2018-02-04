## ROCK64 ayufan's Linux build script

This repository contains a set of scripts to build ROCK64 linux images.

This is community maintained project in my free time. Don't expect everything to be perfect and working. Rather be prepared that there are problems, as always try to fix them and contribute, but if you can't drop the issue here so we can track the progress and resolution of the problem.

### Releases

You can always download [latest stable](https://github.com/ayufan-rock64/linux-build/releases/latest) release. The **releases** are meant to be stable versions.

If you want to test bleeding edge features use one of the [pre-releases](https://github.com/ayufan-rock64/linux-build/releases).
Use pre-releases only if you want to test bleeding edge features.

### Issues

If you have any problems with this build or any of the features do not work, feel free to create a new issue in this repository.

Please include information about the version you are using, a list of connected peripherials and any other details (logs) that can be helpful to understand the root cause of your problems.

### Contributing

Feel free to edit any of the files and send a PR to this repository or any in this organization.

### Components

It uses a bunch of different repositories:
- [kernel](https://github.com/ayufan-rock64/linux-kernel) - patched Rockchip's kernel (4.4),
- [kernel-mainline](https://github.com/ayufan-rock64/linux-mainline-kernel) - patched mainline kernel (>= 4.13),
- [u-boot](https://github.com/ayufan-rock64/linux-u-boot) - patched mainline u-boot,
- [rkbin](https://github.com/ayufan-rock64/rkbin) - precompiled bootloader binary blobs.

Some of the packages are distributed via [PPA](https://launchpad.net/~ayufan/+archive/ubuntu/rock64-ppa/).
The sources of these packages are hosted in [this GitHub organization](https://github.com/ayufan-rock64).

This repository is regularly built by [Jenkins](https://jenkins.ayufan.eu/job/linux-build-rock-64/) and released in [Releases sections](https://github.com/ayufan-rock64/linux-build/releases).

## Usage

You can easily compile everything stored in this repository by ensuring that you meet requirements

### Requirements:

1. At least Ubuntu 16.04 or Debian Stretch,
1. Working [Docker Engine](https://docs.docker.com/engine/installation/),
1. Working [binfmt-misc](recipes/binfmt-misc.md) support,
1. Installed `make` (`sudo apt-get install make`).

### Compilation

1. Enter Docker Shell: `make shell`,
1. Synchronise the sources: `make sync`,
1. Build all variants: `make`.

    ```bash
    $ make shell
    Building environment...
    sha256:0aa8a81c687f58bc9b46e33ea6b5f01188c85874ceb729767dfe882b2783abd2
    Entering shell...
    ayufan@rock64-build-env:~/Sources/linux-build$ make sync
    repo init -u https://github.com/ayufan-rock64/linux-manifests -b default --depth=1 --no-clone-bundle
    remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0

    Your identity is: Kamil Trzciński <ayufan@ayufan.eu>
    If you want to change this, please re-run 'repo init' with --config-name

    repo has been initialized in /home/ayufan/Sources/linux-build
    repo sync -j 20 -c --force-sync
    remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
    Fetching project linux-kernel
    Fetching project linux-mainline-kernel
    Fetching project rkbin
    Fetching project linux-u-boot
    remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
    remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
    Fetching projects:  50% (2/4)  remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
    Fetching projects:  75% (3/4)  remote: Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
    Fetching projects: 100% (4/4), done.
    ayufan@rock64-build-env:~/Sources/linux-build$ make
    ...
    ```

### Targets

The Makefile exposes a number of targets.
See all of them with `make help`.

## Documentation

For technical information, see the following documents:

  * [ayufan-release-contents.md](recipes/ayufan-release-contents.md): Explains the contents of the linux image builds
  * [binfmt-misc.md](recipes/binfmt-misc.md): Run binaries from other architectures (ex: `arm64 on x86_64`)
  * [configure-distcc.md](recipes/configure-distcc.md): Distribute compile jobs across multiple computers
  * [dist-upgrade.md](recipes/dist-upgrade.md): Upgrade from an older build (ex: `0.5.x -> 0.6.x`)
  * [dual-booting.md](recipes/dual-booting.md): Provides a menu to choose your OS/kernel at boot time
  * [flash-spi.md](recipes/flash-spi.md): Flash the SPI memory to enable booting from USB or PXE
  * [kernel-upgrade.md](recipes/kernel-upgrade.md): Upgrade your linux kernel to a newer version

## License

These scripts are made available under the MIT license in the hope they might be useful to others. See LICENSE.txt for details.

## Author

Kamil Trzciński, 2017
