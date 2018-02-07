# Release contents

Linux images are built specifically for the `rock64`.

  * The latest [stable release](https://github.com/ayufan-rock64/linux-build/releases/latest) is `0.5.15`
  * The latest [experimental release](https://github.com/ayufan-rock64/linux-build/releases) is `0.6.x` (updated often)

It is **not recommended** to install a **pre-release** build, except to obtain certain tools such as the `u-boot-flash` image.

This document aims to answer the questions:

  1. [What](#what-is-included) is included in these releases?
  2. [How](#how-are-they-built) are these releases built?
  3. [Can](#can-they-be-trusted) these releases be trusted?
  4. [But](#but-i-want-my-own) can I modify these releases?
  5. [Are](#are-there-alternatives) there alternatives to these releases?

## What is included

Every build contains the following files available for download:

  * Popular Linux distributions (ex: Debian, Ubuntu, Container Linux)
  * Linux kernel and headers
  * Debian package with custom tools, wallpapers, start scripts, etc
  * U-boot flash and erase images (since `0.6.10`)
  * Source code for all build scripts

Let's focus on the Debian package `linux-rock64-package-0.x.x_all.deb`, whose contents can be [found here](https://github.com/ayufan-rock64/linux-build/tree/master/package/root).

This package is installed on all builds. It's essentially the _"custom"_ stuff added to each base OS.

Most files are there to ensure the hardware features of the `rock64` work well. Some scripts can also help with debugging or improving your `rock64` experience:

  * `rock64_health.sh`: outputs the CPU frequency, count, and SoC temperature
  * `rock64_eth0_stats.sh`: outputs statistics about your `eth0` network adapter
  * `install_desktop.sh`: installs a Linux desktop packages if you've installed a `minimal` distribution

It's worth noting, many of these customizations have been borrowed from `pine64`, `armbian`, and other tools designed for SBCs.

## How are they built

A publicly accessible [Jenkins server](https://jenkins.ayufan.eu/job/linux-build-rock-64/) is used to automate creation of various builds. The [full log](https://jenkins.ayufan.eu/job/linux-build-rock-64/lastBuild/console) is available for anyone to see.

The aptly named [linux-build](https://github.com/ayufan-rock64/linux-build) repository contains Makefiles and build scripts for generating each build.

## Can they be trusted

Well, as much as you trust the official Debian or Ubuntu distributions.

A lot of work has been made to ensure visibility into the entire build process, which can't be said for all Linux distributions out there.

You're always free to inspect the sources, build logs, and compare outputs with other similar systems.

## But I want my own

Since all build scripts and sources are available, it is possible to create your own distribution to run on the `rock64`. Many people have done so with systems such as Devuan and RancherOS.

We won't go into details on _how_ to do it, but it's definitely possible if you're knowledgeable with Linux.

## Are there alternatives

There are many options for the `rock64`, depending on your needs. It is possible to run Android, Armbian, Yocto, and a host of other `arm64` systems on the `rock64`.

A comprehensive list of available operating systems are found here:

  * [http://wiki.pine64.org/index.php/ROCK64_Software_Release](http://wiki.pine64.org/index.php/ROCK64_Software_Release)
  * [https://www.armbian.com/rock64/](https://www.armbian.com/rock64/)
  * [https://github.com/ayufan-rock64/linux-build/releases](https://github.com/ayufan-rock64/linux-build/releases)
