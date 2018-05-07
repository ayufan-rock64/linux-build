**Notes**:
- **The RELEASES is the latest stable version**. The pre-release is the latest development version.
- Use u-boot recovery mode selection: https://github.com/ayufan-rock64/linux-u-boot/commit/ea6efecdfecc57c853a6f32f78469d1b2417329b
- To enable upgrading to pre-releases edit `nano /etc/apt/sources.list.d/ayufan-rock64.list`,
- [Buy me a Beer](https://www.paypal.me/ayufanpl)

**OpenMediaVault**:
- Jessie, armhf variant is prefferred as it is stable (OMV 3.0) and offers the best compatibility,
- Use Stretch only for testing (OMV 4.0),

**Xenial / Container Linux**:
- It has Docker Community Edition / Docker Compose / Kubernetes-admin installed for easy Containers use,

**Bionic**:
- The Bionic is development version of upcoming Ubuntu 18.04 LTS it might-not-work,

**Credentials**:
- All variants except OMV: rock64/rock64
- OMV: admin/openmediavault (for Web), root/openmediavault (for Console). To enable SSH for OMV go to Web > SSH > Permit Root Login > Save > Apply

**Upgrade**:
```
sudo apt-get update -y
sudo apt-get install linux-rock64 -y
```

# 0.6.x

- 0.6.33: Verify GitLab CI,
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
