## Notes

- **PRE-RELEASE**: unstable and should be only used for testing purposes
- **Fully reproducible, upgradable and trustable builds, build by CI system**
- Check [Compatibility list](https://docs.google.com/spreadsheets/d/1pCqJg0VSzvihUOoxCOq3wt5JeGB4iApAyBBfc_BGv2A) to get know about the working features of each release
- To enable upgrading to pre-releases edit `nano /etc/apt/sources.list.d/ayufan-rock64.list`
- If you look for kernels, u-boots, or packages (.deb), consider reading the: https://github.com/ayufan-rock64/linux-build#components
- [Buy me a Beer](https://www.paypal.me/ayufanpl)

## Variants

### 1. Desktop

Use **armhf** variant with Ubuntu Mate as one that offers the best compatibility and performance.
Ubuntu Mate is not available for Rock64 as it is simply too slow.

Credentials: rock64/rock64

### 2. Bionic / Container Linux

It has Docker Community Edition / Docker Compose / Kubernetes-admin installed for easy Containers use.

Credentials: rock64/rock64

### 3. OpenMediaVault

Use **armhf** variant as one that offers the best compatibility.

Credentials: admin/openmediavault (for Web), root/openmediavault (for Console).
To enable SSH for OMV go to Web > SSH > Permit Root Login > Save > Apply

### Upgrade

```bash
# Pick one
sudo apt-get update -y && sudo apt-get install linux-rock64-0.8 -y
sudo apt-get update -y && sudo apt-get install linux-rockpro64-0.8 -y
sudo apt-get update -y && sudo apt-get install linux-pinebookpro-0.8 -y

# Upgrade all other packages
sudo apt-get update -y && sudo apt-get dist-upgrade -y

# Remove invalid X11 config, and fix bootloaders
sudo rm /etc/X11/xorg.conf.d/20-armsoc.conf
sudo new_extlinux_boot.sh rootfs
sudo rock64_upgrade_bootloader.sh
```

## Changelog

### 0.8.x

- 0.8.2: Be more strict what packages/kernels are being in use for 0.8.x branch,
- 0.8.1: The final pre-release,
- 0.8.0rc16: Improve glamor support for Rock64,
- 0.8.0rc16: Disable automatic updates,
- 0.8.0rc15: Support brightness controls for Pinebook Pro v2,
- 0.8.0rc15: Support power/lid controls on Pinebook Pro v2,
- 0.8.0rc15: Support charger detection on Pinebook Pro v2,
- 0.8.0rc15: Disable DRAM 928MHz for RockPro64 and Pinebook Pro as it causes instabilities,
- 0.8.0rc15: Fix spurious resume after suspend support for RockPro64 and Pinebook Pro,
- 0.8.0rc15: Disable wake-on-lan support for Rock64 and RockPro64,
- 0.8.0rc14: Enable support for Pinebook Pro v2,
- 0.8.0rc14: Enable i2c0 on Rock64,
- 0.8.0rc14: Enable i2c8 on RockPro64,
- 0.8.0rc13: RockPro64: enable RTC, SPDIF, IR, fix GMAC from suspend,
- 0.8.0rc13: Fix Chromium User Agent to make Netflix happy,
- 0.8.0rc12: Make Rock64 v3 to work, Yay!
- 0.8.0rc11: Fix pcie0 and sdio0 on RockPro64 (it should be always stable),
- 0.8.0rc11: Compile-in CONFIG_PHY_ROCKCHIP_PCIE into kernel,
- 0.8.0rc11: Add `rockpi4b` build-target,
- 0.8.0rc11: Lock DDR freq to 1600MHz on Rock64,
- 0.8.0rc11: Enable 3D acceleration for Rock64,
- 0.8.0rc10: Fix booting mate on Rock64, but without 3D acceleration for now,
- 0.8.0rc9: Fix long start issue due to removed `/etc/machine-id`,
- 0.8.0rc9: Prefer `PageFlip=false` as it removes flickering,
- 0.8.0rc8: Fix display on Pinebook Pro
- 0.8.0rc7: Fix performance regression of xserver,
- 0.8.0rc7: Enable `rga` device for rock/pinebook/pro64
- 0.8.0rc6: Disable `swrast` to improve compositing performance,
- 0.8.0rc6: Enable `compositing-manager` marco for Mate,
- 0.8.0rc6: Fix display of desktop icons for Mate,
- 0.8.0rc6: Prefer `PageFlip=true`,
- 0.8.0rc5: Fix `Bluetooth` failure on desktop load
- 0.8.0rc4: Provide `install_widevine_drm.sh` to install Widevine DRM,
- 0.8.0rc3: Use `xserver` for `rockpro64` and `pinebook-pro` with gles2,
- 0.8.0rc3: Add full support for `pinebook-pro v1`,
- 0.8.0rc3: Provide `armhf` desktop on `mate` as it is quite fast and stable,
- 0.8.0rc3: Provide `gl4es` to run OpenGL1/2 applications with GLES2 acceleration,
- 0.8.0rc3: Style `Ubuntu Mate` with nice wallpapers and pre-configured panels,
- 0.8.0rc3: Configure `Bluetooth` on system start on RockPro64 and PinebookPro,
- 0.8.0rc1: First release with complete rebase of all patches,
- 0.8.0rc1: Fixed Mali, WiFi, BT, Sound, HDMI, Suspend on RockPro64,
- 0.8.0rc1: Fixed `libmali-*` to not conflict with development libraries,

### 0.7.x

- 0.7.14: Update rockchip kernel to 4.4.167,
- 0.7.14: Update mainline kernel to 5.0,
- 0.7.13: Enable support for RockPro64 WiFi/BT module,
- 0.7.13: Fix LXDE build: updated libdrm,
- 0.7.12: Rebased mainline kernel,
- 0.7.12: Rockchip kernel has patches for enabling sdio0 and pcie concurrently,
- 0.7.12: A bunch of dependencies updates,
- 0.7.11: Rebased mainline kernel,
- 0.7.11: Run rockchip kernel at 250Hz to increase performance,
- 0.7.11: Add support for usb gadgets for rockchip,
- 0.7.11: Introduce `change-default-kernel.sh` script to easily switch between kernels,
- 0.7.10: Rebased rockchip and mainline kernels,
- 0.7.10: Support USB gadgets for rock/pro64,
- 0.7.10: Disable TX checksumming for RockPro64,
- 0.7.10: Improve FAN for RockPro64,
- 0.7.10: Improve sdmmc0 stability for Rock64,
- 0.7.10: Enable binfmt-misc,
- 0.7.10: Improve stability of PCIE for RockPro64,
- 0.7.10: Fix eMMC stability on RockPro64 mainline kernel,
- 0.7.9: Fix upgrade problem (u-boot-* packages),
- 0.7.8: Improve eMMC compatibility on RockPro64,
- 0.7.8: Disable sdio (no wifi/bt) to fix pcie/nvme support on 4.4 for RockPro64,
- 0.7.8: Fix OMV builds (missing initrd.img),
- 0.7.8: Make all packages virtual, conflicting and replacing making possible to do `linux-rock64/rockpro64` to replace basesystem,
- 0.7.7: Fix memory corruptions caused by Mali/Display subsystem (4.4),
- 0.7.7: Enable SDR104 mode for SD cards (this requires u-boot upgrade if booting from SD),
- 0.7.6: Change OPP's for Rock64 and RockPro64: https://github.com/ayufan-rock64/linux-kernel/compare/4.4.132-1059-rockchip-ayufan...ayufan-rock64:4.4.132-1062-rockchip-ayufan,
- 0.7.5: Various stability fixes for kernel and u-boot,
- 0.7.5: Added memtest to kernels and extlinux,
- 0.7.5: Show early boot log when booting kernels,
- 0.7.4: Fix `resize_rootfs.sh` script to respect boot flags (fixes second boot problem introduced by 0.7.0),
- 0.7.4: Add rock(pro)64_erase_spi_flash.sh,
- 0.7.4: Fix cursor on desktop for rockpro64,
- 0.7.3: Fix generation of extlinux.conf (linux booting),
- 0.7.2: Pin packages,
- 0.7.2: Improve performance of build process,
- 0.7.1: Use GitLab CI for releasing all images,
- 0.7.0: Introduces heavy refactor splitting all components into separate repos, and separate independent releases (u-boot, kernel, kernel-mainline, compatibility package),
- 0.7.0: Dry run everything,

### 0.6.x

- 0.6.60: Fix pcie/nvme/sata support for 4.4,
- 0.6.60: Fix spi-flash access for 4.4/mainline,
- 0.6.59: Fix u-boot dtb: fixes reboot, cpu stability issues, usb2/type-c booting,
- 0.6.59: Enable leds support in u-boot,
- 0.6.59: Fix rock64_upgrade_bootloader.sh script,
- 0.6.59: Fix extlinux kernel sorting,
- 0.6.59: Copy-paste evb_rk3399 to rockpro64_rk3399 in u-boot,
- 0.6.59: Use proper `fcs,suspend-voltage-selector` for `vdd_cpu_b` on mainline kernel,
- 0.6.59: Rebase mainline kernel on 4.18.0-rc3 (requires 0.6.59 u-boot),
- 0.6.59: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/40e877458b0dd3fedc39afc8c2a8e428adafc858,
- 0.6.58: Enable AHCI in 4.4 kernel making pcie-sata bridge to work,
- 0.6.58: Introduce `new_extlinux_boot.sh` that uses `/` for booting and allows to choose any kernel,
- 0.6.58: Properly assign pcie/ahci/eth0 for rockpro64,
- 0.6.58: Enable USB3 on mainline kernel,
- 0.6.57: Make HDMI a first audio device for rockpro64,
- 0.6.57: Remove some of the failures from bootlog,
- 0.6.57: Temporarily disable GPU,
- 0.6.56: Remove dma plat init to have bigger buffers everywhere :)
- 0.6.55: Make rockchip phy drivers to be built-in,
- 0.6.54: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/6a9bb29aa09b,
- 0.6.53: Support eMMC booting,
- 0.6.53: Compile a lot of stuff as kernel modules,
- 0.6.52: Enable dfi/dmc,
- 0.6.52: Revert DMA patches,
- 0.6.52: Make PCIE and HDMI an kernel module,
- 0.6.51: Fix hdmi output, enable hdmi sound,
- 0.6.50: Disable mali and vdd_gpu, and overvolt big cores a little to increase stability,
- 0.6.49: Disable force sram for rockchip snd soc,
- 0.6.48: Test re-enabling mali for android on rockpro64,
- 0.6.47: Disable mali as it causes kernel panic on rockpro64 for now,
- 0.6.46: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/f113aefebc63513f4f90810a6ee0f5e9f1a34846,
- 0.6.45: Improve rockpro64 support,
- 0.6.45: Reduce timeouts to speed-up the boot (u-boot, extlinux)
- 0.6.44: Bring back clock changes for DDR, enable DMC,
- 0.6.43: Revert rk3328 clock changes for DDR,
- 0.6.42: Disable complation of dfi/dmc/suspend/fiq/vendor storage,
- 0.6.42: Disable dmc/dfi for memory,
- 0.6.42: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/3dd9af3221d2a4ea4caf2865bac5fe9aaf2e2643,
- 0.6.42: RockPro64: use 933MHz DDR config,
- 0.6.42: Add additional opp for cpu/mem,
- 0.6.42: Enable dmc for memory,
- 0.6.42: Fix USB3 and leds control on RockPro64 (and maybe pcie),
- 0.6.42: Install proper mali driver for RockPro64,
- 0.6.42: Make ethernet somehow stable on RockPro64,
- 0.6.41: Revert dma changes to before 0.6.39,
- 0.6.41: Revert tx/rx gmac changes to before 0.6.13,
- 0.6.40: Disable unused nodes for rock64 to improve stability,
- 0.6.39: Use HS mode for u-boot when reading eMMC/SD,
- 0.6.39: Disable rockchip_suspend as it causes instability,
- 0.6.38: Bump ddr loader to 1.13, and disable DFI,
- 0.6.37: Disable kubelet/zram-config for Containers,
- 0.6.37: Remove duplicate vcc-sys,
- 0.6.36: Support bionic's netplan,
- 0.6.36: Build only: Bionic Minimal/Containers/LXDE and Stretch Minimal/OpenMediaVault,
- 0.6.35: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/b075e3b123bda312b2997492b1e939f075c26031,
- 0.6.35: Rebase mainline kernel on https://github.com/rockchip-linux/kernel/commit/fff75eb2a08c2ac96404a2d79685668f3cf5a7a3,
- 0.6.34: Release all variants, including desktop,
- 0.6.33: Bionic stable release,
- 0.6.32: Bump bionic and jessie/stretch openmediavault releases to latest version,
- 0.6.31: Include additional kernel modules: https://github.com/ayufan-rock64/linux-kernel/pull/25,
- 0.6.30: Include additional kernel modules: https://github.com/ayufan-rock64/linux-kernel/pull/24,
- 0.6.30: Improve compatibility of `u-boot-rock64` package,
- 0.6.29: Enable additional Realtek WiFi modules (ex. AC adapter),
- 0.6.29: Introduce `u-boot-rock64` which can be used for upgrading bootloader,
- 0.6.29: Add `rock64_reset_emmc.sh` script which can be used with eMMC jumper to easily flash eMMC from SD,
- 0.6.29: Improve thermal limits to make cpuburn to run stable,
- 0.6.28: Fix soft boot issue: boot with DDR333, and then use DFI to configure RAM speed: it has negative effect on mainline, running only in DDR333,
- 0.6.27: Fix not booting issue introduced in 0.6.26,
- 0.6.27: Disable eth1 by default, ask for enabling it,
- 0.6.26: Add USB quirks to kernel, instead of modules,
- 0.6.26: Do not enable quirks on boot, thus do not upgrade initrd, and prevent the flash-kernel from executing,
- 0.6.26: Enable bunch of kernel modules for 4.4,
- 0.6.26: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/7482a49a2de6,
- 0.6.26: Rebase mainline kernel on https://github.com/torvalds/linux/commit/1b5f3ba415fe,
- 0.6.25: Make HDMI a first audio device,
- 0.6.25: Add lxde desktop environment,
- 0.6.25: Add `rkmpv` to simplify video playback,
- 0.6.25: Update libmali, ffmpeg, mpv, and xf86-video-armsoc,
- 0.6.25: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/eae92ae2b930999857df47c3057327c1c490454b,
- 0.6.25: Reabse mainline kernel on https://github.com/torvalds/linux/commit/5d60e057d127538113d8945ea87d916fccee93fe,
- 0.6.24: Use armsoc for X11,
- 0.6.24: Improve libmali and extend install_desktop to support LXDE/XFCE4/Gnome,
- 0.6.24: Fix flash-kernel causing bionic to fail,
- 0.6.24: Include additional wireless drivers from Xalius,
- 0.6.24: Make extlinux to use dual-boot to allow to choose current, or previous kernel,
- 0.6.23: Disable CONFIG_SCHED_WALT to increase system stability,
- 0.6.22: Rebase 4.4 kernel on https://github.com/rockchip-linux/kernel/commit/7b43537ed9213dbc8994d3d2789e84b8c37cd454,
- 0.6.21: Include BL31 in bootloader, this fixes kernel booting,
- 0.6.20: Fix HDMI and USB2.0 on 4.4 kernel,
- 0.6.19: Fix 4.4 kernel emmc and gmac2io ordering, to be always first,
- 0.6.18: Fix 4.4 kernel not booting,
- 0.6.17: Rebase and flatten all kernel patches on top of rockchip-4.4,
- 0.6.17: Enable dvfs for DRAM,
- 0.6.16: Limit USB3 to HS mode in u-boot,
- 0.6.15: Introduce Containers Linux: it has bundled latest Docker Community Edition, Docker Compose and Kubernetes tools,
- 0.6.15: Introduce OpenMediaVault 4.0 Stretch edition (alpha/alpha)
- 0.6.14: Fix USB3 booting from SPI,
- 0.6.14: Fix leds handling in Linux,
- 0.6.13: Tune tx/rx delay for gmac2io to make it stable without additional userspace quirks on: 4.4 kernel, 4.15 kernel and in u-boot (PXE booting is possible now! yay!).
- 0.6.13: The 4.4 and 4.15 kernels do support configfs dt overlays,
- 0.6.13: Enable ZRAM support for mainline,
- 0.6.12: Use older ATF (for rk322xh) which solves serial/ethernet address and booting of mainline kernel: https://github.com/ayufan-rock64/arm-trusted-firmware/commit/f947c7e05a34db0c5b908a5347184fcaa9a32d95
- 0.6.11: Use different delays for u-boot PXE to make it work,
- 0.6.10: Add images to flash u-boot to SPI,
- 0.6.10: Fix rock64_write|erase_spi_flash.sh,
- 0.6.9: Fix USB booting from OTG,
- 0.6.9: Enable SPI support for Winbond in u-boot,
- 0.6.9: Introduce recovery button mode selection: https://github.com/ayufan-rock64/linux-u-boot/commit/ea6efecdfecc57c853a6f32f78469d1b2417329b,
- 0.6.9: Enable control of rk805 leds from u-boot,
- 0.6.9: The rock64_write|erase_spi_flash.sh check MTD name,
- 0.6.8: Fix rock64_write|erase_spi_flash.sh scripts,
- 0.6.7: Fix u-boot booting (regression since 0.6.6),
- 0.6.6: Fix eMMC not working since 0.6.1,
- 0.6.6: U-boot supports USB2/3 booting,
- 0.6.6: Use Rockchip's u-boot tree,
- 0.6.5: Tag all dependent repositories,
- 0.6.4: Include mainline kernel in release,
- 0.6.3: Rebase mainline kernel and u-boot patches,
- 0.6.3: Fix libmali (make it work),
- 0.6.3: Fix small bug in `rock64_write_spi_flash.sh`,
- 0.6.2: Use RK DDR and SPL (allows SPI booting),
- 0.6.2: Release bionic instead of artful,
- 0.6.2: Include a bunch of updated drivers: xserver, libdrm, xf86-video-armsoc, etc.,
- 0.6.2: Include updated 4.4 kernel,
- 0.6.1: Make SPL/TPL actually to work,
- 0.6.1: Introduce `rock64_write_spi_flash.sh` and `rock64_erase_spi_flash.sh`,
- 0.6.0: **Highly experimental**,
- 0.6.0: Use SPL/TPL instead of Rockchip's loaders (supports flashing and booting from SPI),

### 0.5.x

- 0.5.15: Include additional USB3 patch to fix disconnection/reconnection problems (only 4.4 kernel),
- 0.5.14: Include USB3 patches to fix disconnection/reconnection problems (only 4.4 kernel),
- 0.5.13: Compile kernel in a way that allows building own modules on target system,
- 0.5.12: Add missing `ifupdown` for artful,
- 0.5.11: Support eMMC 5.1 on Mainline kernel,
- 0.5.11: Install firmware-realtek or linux-firmware to support wireless drivers,
- 0.5.11: Fix Ubuntu Artful image,
- 0.5.11: Rebase u-boot to include PMIC support,
- 0.5.10: Include CONFIG_KEYS_COMPAT, needed by Docker,
- 0.5.10: Include missing headers to build kernel modules,
- 0.5.10: Build i3/mate only for arm64,
- 0.5.10: Build OMV for armhf/arm64,
- 0.5.9: Resize on first boot,
- 0.5.9: Build Artful minimal images,
- 0.5.8: Include more Docker modules, include latest u-boot,
- 0.5.7: Include a bunch of kernel modules to make Docker work beautifully :)
- 0.5.6: Make rock64-offload do work on mainline kernel,
- 0.5.6: Enable CPU freq scaling on mainline kernel,
- 0.5.6: Enable additional CPU gov, make ondemand to be default one,
- 0.5.5: Apply @Kwiboot patch for working sound rates: https://github.com/Kwiboo/linux-rockchip/commit/a777086128c75d43ee64772f619b4839c06853de,
- 0.5.5: Move USB2.0 to separate IRQ, thanks @tkaiser,
- 0.5.5: Enable a bunch of kernel modules (USB, crypto, network) for Mainline kernel,
- 0.5.4: Apply on top of Rockchip kernel @Kwiboo patches for sound: https://github.com/Kwiboo/linux-rockchip/compare/rockchip-4.4...rockchip-4.4-pl330.patch,
- 0.5.4: Pass eth1addr to Linux,
- 0.5.4: Mainline kernel: cherry-pick internal gmac2phy, rk805 with pwrkey and leds,
- 0.5.4: Make mainline kernel to see emmc and sd, and be able to do pxe/nfs boot,
- 0.5.3: Make images to boot,
- 0.5.2: Ethernet address is calculated from serial,
- 0.5.2: Add SPI support in u-boot,
- 0.5.2: PXE booting always uses 100Mbps for reliability,
- 0.5.2: Power USB2.0 ports,
- 0.5.2: Rebase rockchip-kernel,
- 0.5.2: Expose standby and power leds,
- 0.5.2: Include some sound changes from Kwiboo,
- 0.5.1: Fix mainline kernel booting,
- 0.5.1: Remove eth1 (internal phy) as it is not yet working properly,
- 0.5.0: Use mainline u-boot: https://github.com/ayufan-rock64/linux-u-boot/tree/mainline-master with USB and PXE booting support,
- 0.5.0: Make mainline kernel to be usable and enable USB2/3 and GMAC,

- 0.4.17: Improve rock64_fix_performance.sh (Thanks @tkaiser),
- 0.4.17: Improve rock64_diagnostics.sh (Thanks @pfeerick),
- 0.4.17: Add ntp to all builds,
- 0.4.16: Revert kernel to older version as the current seems to crash on 1/2GB: https://github.com/ayufan-rock64/linux-kernel/commit/933b62ebe1c0cb734d84c38bf14eb7d60688611a,
- 0.4.16: fake-hwclock save and properly enable ntp,
- 0.4.15: Add fake-hwclock, usbutils, sysstat, fping, iperf3 and iozone3
- 0.4.14: Fix persistence of ethernet address,
- 0.4.14: Move mtdparts to dtb (requires upgraded kernel and support package),
- 0.4.14: Release mainline kernel alongside (https://github.com/ayufan-rock64/linux-mainline-kernel),
- 0.4.14: Disable rrdcached for OpenMediaVault,
- 0.4.13: Set coherent_pool and fix login as root over UART,
- 0.4.12: Fix eth0 configuration for OpenMediaVault,
- 0.4.11: Improve rrdcached and interfaces configuration for OpenMediaVault,
- 0.4.10: Disallow root login,
- 0.4.9: Disable password change for root (leave for rock64),
- 0.4.8: Force password change on boot,
- 0.4.8: OMV build uses root/openmediavault,
- 0.4.7: Enable rrdcached back for OMV build,
- 0.4.6: Improve OpenMediaVault settings (Thanks @tkaiser), revert 1.4GHz OPP,
- 0.4.5: Include rock64_diagnostics.sh
- 0.4.4: dts: enable 1.4Ghz / 1.35V operating point for testing (Thanks @xalius)
- 0.4.3: dts: Fix HS-200 eMMC bus mode (Thanks @xalius),
- 0.4.2: dts: Remove SDIO wifi support (Thanks @xalius),
- 0.4.1: Fix fix_irqs.sh not being run on startup,
- 0.4.0: Make glamor rendering twice faster,
- 0.4.0: Make resize_rootfs.sh to work with SD and eMMC,
- 0.4.0: Merge https://github.com/Kwiboo/linux-rockchip that includes internal phy, vpu set to 600MHz, and other smaller fixes,

### 0.3.x

- 0.3.7: Disable RK_PARTITION support (needed by Android) and enable additional kernel modules: https://github.com/ayufan-rock64/linux-kernel/commit/17cebdba56f7eded8b1a02ecc46d6a34950a566b,
- 0.3.6: Use labels to choose boot and root device,
- 0.3.5: Tinker with making mmc0 to be always eMMC, mmc1 to be always SD and making image to be multibootable,
- 0.3.4: Update kernel config and dts,
- 0.3.3: Build ARM64 of Mate and i3 with Mali drivers,
- 0.3.2: Fix flash-kernel config and make it bootable,
- 0.3.1: Read/Write mac address to mtd,
- 0.3.1: MTD has partitions,
- 0.3.0: Not compatible with 0.2.x due to change in partition layout:
- 0.3.0: Use /boot/efi located at /dev/mmcblk0p6 and / located at /dev/mmcblk0p7

### 0.2.x

- Enable SPI Flash for Linux,
- Add linux-rock64 a virtual package that depends on linux-rock64-package and linux-image-*-ayufan-*,
- Add rock64_fix_irqs executed at boot,
- Include landscape,
- Include ethernet and health scripts,
- Fix Kernel config,
- Create OpenMediaVault image,
- Distribute Debian Jessie and Stretch,
- Extend kernel config to include more filesystem and network modules,
- Disable TX offloading as it makes GbE unstable,
- Include recent kernel/u-boot and bl31_v1.34 fixes,
- Add arm64 as foreign architecture for armhf builds,
- Use single partition for boot and root,
- Use linux image deb with flash-kernel,

### 0.1.x

- Make u-boot less noisy,
- Dist-upgrade system to fix Mali,
- Support 1/2/4GB model,
- Include ppa:ayufan/rock64-ppa with Mali drivers,
- Update u-boot and kernel,

### 0.0.x

- Initial release,
- Build armhf release,
- Use new docker building system,
