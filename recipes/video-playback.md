# Video playback (experimental)

**This only works on Ubuntu Bionic image.**

The [ayufan's ppa](https://launchpad.net/~ayufan/+archive/ubuntu/rock64-ppa) contains the latest compiled FFmpeg and mpv which allows to use HW video acceleration when properly configured.

The modified FFmpeg includes an `h264_rkmpp`, `hevc_rkmpp`, `vp8_rkmpp` and `vp9_rkmpp` video decoders.

## Install

First, install needed packages

```bash
apt-get install ffmpeg mpv libmali-rk-utgard-450-r7p0-gbm
```

Keep in mind that installing `libmali-rk-utgard-450-r7p0-gbm` will make GLES not working, as this is the only library that allows us to use DRM/atomic which allows fully accelerated video decoding in fullscreen.

If you want to bring back support for GLES in X11, ensure to revert back to:

```bash
apt-get install libmali-rk-utgard-450-r7p0
```

## Run

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

## Thanks

You should thank [LongChair](https://github.com/LongChair) and [Kwiboo](https://github.com/Kwiboo/) for making this work!
