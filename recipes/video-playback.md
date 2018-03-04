# Video playback (experimental)

**This only works on Ubuntu Bionic image.**

The [ayufan's ppa](https://launchpad.net/~ayufan/+archive/ubuntu/rock64-ppa) contains the latest compiled FFmpeg and mpv which allows to use HW video acceleration when properly configured.

The modified FFmpeg includes an `h264_rkmpp`, `hevc_rkmpp`, `vp8_rkmpp` and `vp9_rkmpp` video decoders.

## Latest releases (>= 0.6.25)

### Requirements

- `libmali-rk-utgard-450-r7p0` installed, at least the `1.6-1ayufan9`
- `linux-rock64-package` installed, at least the `0.6.25``
- `linux-image` installed, at least the `4.4.112-rockchip-ayufan-191`

You can check package version with `apt-cache policy linux-rock64-package`.

### Use

Use `rkmpv` that will configure `mpv` for HW accelerated video playback:

```bash
rkmpv file.mkv
```

## For older releases (< 0.6.25)

### Install

First, install needed packages

```bash
apt-get install ffmpeg mpv libmali-rk-utgard-450-r7p0-gbm
```

Keep in mind that installing `libmali-rk-utgard-450-r7p0-gbm` will make GLES not working, as this is the only library that allows us to use DRM/atomic which allows fully accelerated video decoding in fullscreen.

If you want to bring back support for GLES in X11, ensure to revert back to:

```bash
apt-get install libmali-rk-utgard-450-r7p0
```

### Verify

Make sure that you use correct versions of FFmpeg and mpv from [ayufan's ppa](https://launchpad.net/~ayufan/+archive/ubuntu/rock64-ppa) with `apt-cache policy ffmpeg mpv`:

```text
ffmpeg:
  Installed: 7:3.5~git20180113-1ayufan2
  Candidate: 7:3.5~git20180113-1ayufan2
  Version table:
 *** 7:3.5~git20180113-1ayufan2 990
        990 http://ppa.launchpad.net/ayufan/rock64-ppa/ubuntu bionic/main arm64 Packages
        100 /var/lib/dpkg/status
     7:3.4.2-1 500
        500 http://ports.ubuntu.com/ubuntu-ports bionic/universe arm64 Packages
mpv:
  Installed: 0.28.0-1ayufan3
  Candidate: 0.28.0-1ayufan3
  Version table:
 *** 0.28.0-1ayufan3 990
        990 http://ppa.launchpad.net/ayufan/rock64-ppa/ubuntu bionic/main arm64 Packages
        100 /var/lib/dpkg/status
     0.27.0-2ubuntu4 500
        500 http://ports.ubuntu.com/ubuntu-ports bionic/universe arm64 Packages
```

### Run

```bash
mpv --vo=gpu --gpu-context=drm --hwdec=rkmpp video.mkv
```

It will start fullscreen video playback. You should see something like this:

```text
Playing: video.mkv
 (+) Video --vid=1 (*) (h264 1280x640 23.976fps)
 (+) Audio --aid=1 --alang=eng (*) (aac 2ch 44100Hz)
     Subs  --sid=1 --slang=eng (subrip)
[vo/gpu] VT_GETMODE failed: Inappropriate ioctl for device
[vo/gpu/opengl] Failed to set up VT switcher. Terminal switching will be unavailable.
[vo/gpu/opengl] Could not choose EGLConfig!
mpi: mpp version: Without VCS, under bleeding
AO: [pulse] 44100Hz stereo 2ch float
Using hardware decoding (rkmpp).
VO: [gpu] 1280x640 drm_prime[nv12]
...
```

### Alternative way

It is possible to have GLES2 and MPV working without reinstalling the package over and over.

```bash
mkdir -p /usr/lib/aarch64-linux-gnu/gbm
cd /usr/lib/aarch64-linux-gnu/gbm
wget https://github.com/ayufan-rock64/libmali/raw/rockchip/lib/aarch64-linux-gnu/libmali-utgard-450-r7p0-gbm.so
ln -sf libmali-utgard-450-r7p0-gbm.so libMali.so
ln -sf libmali-utgard-450-r7p0-gbm.so libgbm.so
ln -sf libmali-utgard-450-r7p0-gbm.so libgbm.so.1
ln -sf libmali-utgard-450-r7p0-gbm.so libgbm.so.1.0.0
```

And then using `LD_PRELOAD_PATH` to instruct `mpv` to use different library:

```bash
LD_PRELOAD_PATH=/usr/lib/aarch64-linux-gnu/gbm mpv --vo=gpu --gpu-context=drm --hwdec=rkmpp video.mkv
```

## Thanks

You should thank [LongChair](https://github.com/LongChair) and [Kwiboo](https://github.com/Kwiboo/) for making this work!
