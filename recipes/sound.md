# Changing sound device

Rock64 and RockPro64 has a number of sound devices.

You can easily list and change sound devices, and easily test them:

## List all sound devices

```bash
$ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: I2S [I2S], device 0: ff010000.i2s-rk3328-hifi rk3328-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 0: I2S [I2S], device 1: ff010000.i2s-snd-soc-dummy-dai snd-soc-dummy-dai-1 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: SPDIF [SPDIF], device 0: ff030000.spdif-dit-hifi dit-hifi-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 2: HDMI [HDMI], device 0: ff000000.i2s-i2s-hifi i2s-hifi-0 []
  Subdevices: 0/1
  Subdevice #0: subdevice #0
```

## Test given sound device

Get an audio device name:

```bash
$ aplay -L
default
    Playback/recording through the PulseAudio sound server
null
    Discard all samples (playback) or generate zero samples (capture)
pulse
    PulseAudio Sound Server
sysdefault:CARD=I2S
    I2S, 
    Default Audio Device
dmix:CARD=I2S,DEV=0
    I2S, 
    Direct sample mixing device
dmix:CARD=I2S,DEV=1
    I2S, 
    Direct sample mixing device
dsnoop:CARD=I2S,DEV=0
    I2S, 
    Direct sample snooping device
dsnoop:CARD=I2S,DEV=1
    I2S, 
    Direct sample snooping device
hw:CARD=I2S,DEV=0
    I2S, 
    Direct hardware device without any conversions
hw:CARD=I2S,DEV=1
    I2S, 
    Direct hardware device without any conversions
plughw:CARD=I2S,DEV=0
    I2S, 
    Hardware device with all software conversions
plughw:CARD=I2S,DEV=1
    I2S, 
    Hardware device with all software conversions
sysdefault:CARD=SPDIF
    SPDIF, 
    Default Audio Device
dmix:CARD=SPDIF,DEV=0
    SPDIF, 
    Direct sample mixing device
dsnoop:CARD=SPDIF,DEV=0
    SPDIF, 
    Direct sample snooping device
hw:CARD=SPDIF,DEV=0
    SPDIF, 
    Direct hardware device without any conversions
plughw:CARD=SPDIF,DEV=0
    SPDIF, 
    Hardware device with all software conversions
sysdefault:CARD=HDMI
    HDMI, 
    Default Audio Device
dmix:CARD=HDMI,DEV=0
    HDMI, 
    Direct sample mixing device
dsnoop:CARD=HDMI,DEV=0
    HDMI, 
    Direct sample snooping device
hw:CARD=HDMI,DEV=0
    HDMI, 
    Direct hardware device without any conversions
plughw:CARD=HDMI,DEV=0
    HDMI, 
    Hardware device with all software conversions
```

Test given audio device:

```bash
speaker-test -c 2 sysdefault:CARD=HDMI
```

## Changing default audio device

When running X11, you can easily change default device:

Get a name of the device:

```bash
$ pactl list sinks
```

Set a default device:

```bash
$ pactl set-default-sink alsa_output.platform-hdmi-sound.stereo-fallback
```
