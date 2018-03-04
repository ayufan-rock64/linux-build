# Compilation

You can easily compile everything stored in this repository by ensuring that you meet requirements

## Requirements

1. At least Ubuntu 16.04 or Debian Stretch,
1. Working [Docker Engine](https://docs.docker.com/engine/installation/),
1. Working [binfmt-misc](binfmt-misc.md) support,
1. Installed `make` (`sudo apt-get install make`).

## Compile yourself

1. Enter Docker Shell: `make shell`,
1. Synchronise the sources: `make sync`,
1. Build all variants: `make`.

    ```bash
    $ make shell
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

## Targets

The Makefile exposes a number of targets.
See all of them with `make help`.
