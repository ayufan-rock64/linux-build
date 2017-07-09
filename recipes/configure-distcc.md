## Distcc FTW!

To speed-up on Pine A64/Rock64 compilation you can use external machine,
which is usually much more powerful (PC with Debian/Ubuntu).

## 1. On your server:

Install distcc and cross-compiler:

```bash
apt-get install distcc gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
```

## 2. Configure distcc server:

Edit `/etc/default/distcc`:

```
STARTDISTCC="true"

# Type network address in which your Rock/Pine is running
ALLOWEDNETS="127.0.0.1 192.168.88.0/24"
LISTENER="0.0.0.0"

# Define maximum number of jobs
JOBS="4"
```

## 3. Start distcc:

```bash
systemctl enable distcc
systemctl start distcc
```

## 4. On your Pine A64/Rock 64:

Install distcc and ccache:

```bash
apt-get install -y distcc ccache
```

## 5. Configure your Pine A64/Rock 64 environment:

When compiling for arm64 edit `/etc/environment`:

```
DISTCC_HOSTS=192.168.70.124/4 #
CCACHE_PREFIX=distcc
CC="ccache aarch64-linux-gnu-gcc"
CXX="ccache aarch64-linux-gnu-g++"
```

When compiling for armhf edit `/etc/environment`:

```
DISTCC_HOSTS=192.168.70.124/4
CCACHE_PREFIX=distcc
CC="ccache arm-linux-gnueabi-gcc"
CXX="ccache arm-linux-gnueabi-g++"
```

Change `192.168.70.124/4` to point to your distcc server.
The `/4` defines maximum jobs to be executed by your Pine A64/Rock 64, in this case it is `/4`.

## 6. Finally

Logout, and login again.

For all new compilations you should be using `ccache` on your device, and use external (over network) compilation machine with `distcc`.


