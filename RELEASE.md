**Notes**:
- **The RELEASES is the latest stable version**. The pre-release is the latest development version.
- Use u-boot recovery mode selection: https://github.com/ayufan-rock64/linux-u-boot/commit/ea6efecdfecc57c853a6f32f78469d1b2417329b
- To enable upgrading to pre-releases edit `nano /etc/apt/sources.list.d/ayufan-rock64.list`,
- If you look for kernels, u-boots, or packages (.deb), consider reading the: https://github.com/ayufan-rock64/linux-build#components,
- [Buy me a Beer](https://www.paypal.me/ayufanpl)

**OpenMediaVault**:
- Use armhf variant as one that offers the best compatibility,

**Bionic / Container Linux**:
- It has Docker Community Edition / Docker Compose / Kubernetes-admin installed for easy Containers use,

**Credentials**:
- All variants except OMV: rock64/rock64
- OMV: admin/openmediavault (for Web), root/openmediavault (for Console). To enable SSH for OMV go to Web > SSH > Permit Root Login > Save > Apply

**Upgrade**:
```
sudo apt-get update -y
sudo apt-get install linux-rock64 -y
sudo apt-get install linux-rockpro64 -y
```

# 0.7.x

- 0.7.1: Use GitLab CI for releasing all images,
- 0.7.0: Introduces heavy refactor splitting all components into separate repos, and separate independent releases (u-boot, kernel, kernel-mainline, compatibility package),
- 0.7.0: Dry run everything,

# 0.6.x

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
