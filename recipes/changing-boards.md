# Changing boards (highly experimental)

If you use any of my images it is possible to switch between boards (Rock64 and RockPro64) without reinstalling system, but just swapping SD/eMMC card.

## Prepare old image (if you run < 0.7.0)

For older installations running image older than `< 0.7.0` (0.5.x and 0.6.x),
first you have to prepare system to support new booting scheme.

Run this command as root:

```bash
apt-get update
apt-get dist-upgrade
new_extlinux_boot.sh rootfs
```

Reboot to ensure that everything still works.

_If not, well create an issue and we will try to fix it._

## Upgrading the system to a new board

**ALL THESE COMMANDS TO BE RUN ON THE OLD BOARD.**

Procedure is simple:

1. We install compatibility package for target board, like rock64 or rockpro64 (still on old board),
2. We upgrade bootloader for target board (still on old board),
3. We shutdown system,
4. We run the SD/eMMC from the new board.

### Rock64 -> RockPro64

On the `Rock64` run:

```bash
apt-get install -y linux-rockpro64
```

Then upgrade bootloader, still on `Rock64`:

```bash
rock64_upgrade_bootloader.sh
```

Shutdown system:

```bash
halt
```

Swap the card to `RockPro64` and the system should boot just fine.

### RockPro64 -> Rock64

On the `RockPro64` run:

```bash
apt-get install -y linux-rock64
```

And then upgrade bootloader, still on `Rock64`:

```bash
rock64_upgrade_bootloader.sh
```

Shutdown system:

```bash
halt
```

Swap the card to `RockPro64` and the system should boot just fine.

## Known problems

- Experimental, may not work,
- It does not upgrade mali drivers.
