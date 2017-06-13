FROM ubuntu as buildsystem

RUN apt-get update -qq -y
RUN apt-get install -qq -y debootstrap qemu-user-static

ARG BUILD_ARCH=arm64
ARG BUILD_SUITE=xenial
ARG BUILD_ESSENTIAL_PACKAGES=ubuntu-minimal,dosfstools,curl,xz-utils,iw,rfkill,wpasupplicant,openssh-server,alsa-utils,nano,git,build-essential,vim,jq,systemd,systemd-sysv,udev,apt,kmod,locales,sudo,netbase,net-tools,ethtool,iproute,iputils-ping,ifupdown,dhcpcd5,wpasupplicant,ssh,avahi-daemon,ntp,wireless-tools,wget
ARG BUILD_COMPONENTS=main,restricted,universe,multiverse

RUN debootstrap \
    --arch=$BUILD_ARCH \
    --verbose \
    --foreign \
    --components=$BUILD_COMPONENTS \
    --include=$BUILD_ESSENTIAL_PACKAGES \
    $BUILD_SUITE \
    /rootfs

RUN cp -Rv /usr/bin/qemu-aarch64-static /rootfs/usr/bin
RUN cp -Rv /usr/bin/qemu-arm-static /rootfs/usr/bin
RUN cp -Rv /usr/share/keyrings /rootfs/usr/share/

# ---

FROM scratch as rootfs
COPY --from=buildsystem /rootfs /

# Finish system installation
RUN echo "setup_proc () { true; }" >> /debootstrap/functions
RUN /debootstrap/debootstrap --second-stage

# Update APT sources
ARG BUILD_SUITE=xenial
RUN ( echo "deb http://ports.ubuntu.com/ ${BUILD_SUITE} main restricted universe multiverse" && \
      echo "deb-src http://ports.ubuntu.com/ ${BUILD_SUITE} main restricted universe multiverse" && \
      echo "deb http://ports.ubuntu.com/ ${BUILD_SUITE}-updates main restricted universe multiverse" && \
      echo "deb-src http://ports.ubuntu.com/ ${BUILD_SUITE}-updates main restricted universe multiverse" && \
      echo "deb http://ports.ubuntu.com/ ${BUILD_SUITE}-security main restricted universe multiverse" && \
      echo "deb-src http://ports.ubuntu.com/ ${BUILD_SUITE}-security main restricted universe multiverse" ) \
    > /etc/apt/sources.list

# Disable services startup
RUN echo exit 101 > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

# this is needed to fix resolvconf dpkg-configure
RUN touch /var/lib/resolvconf/linkified
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -f install
RUN apt-get update -y -qq
RUN apt-get dist-upgrade -y
RUN locale-gen en_US.UTF-8

ARG BUILD_ADDITIONAL_PACKAGES=
RUN apt-get install -y $BUILD_ADDITIONAL_PACKAGES

ARG BUILD_VARIANT_PACKAGES=
RUN apt-get install -y $BUILD_VARIANT_PACKAGES

# Install linux-package
ADD /linux-package.deb /
RUN dpkg -i linux-package.deb && \
    rm linux-package.deb

ARG BUILD_VARIANT=minimal
RUN [ "$BUILD_VARIANT" = "minimal" ] || \
    ( install_desktop.sh "$BUILD_VARIANT" && systemctl set-default graphical.target )

ARG BUILD_MODEL=rock64
RUN adduser --gecos "$BUILD_MODEL" --disabled-login "$BUILD_MODEL" --uid 1000 && \
    chown -R 1000:1000 "/home/$BUILD_MODEL" && \
    echo "$BUILD_MODEL:$BUILD_MODEL" | chpasswd && \
    usermod -a -G sudo,adm,input,video,plugdev "$BUILD_MODEL" && \
    sed -i 's|After=rc.local.service|#\0|;' "/lib/systemd/system/serial-getty@.service"

# Cleanup system
RUN apt-get clean && \
    rm -f /usr/bin/qemu-*-static /usr/sbin/policy-rc.d

# ---

FROM ubuntu
RUN apt-get update -qq -y
RUN apt-get install -qq -y build-essential git-core zlib1g-dev
RUN git clone https://github.com/superr/make_ext4fs
RUN make -C make_ext4fs

COPY --from=rootfs / /rootfs

# Fix rootfs
RUN rm -rf /rootfs/dev/* && \
    mkdir -p /rootfs/dev /rootfs/sys /rootfs/proc && \
    rm -f /rootfs/etc/ssh/ssh_host_* && \
    ln -f -s /run/resolvconf/resolv.conf /rootfs/etc/resolv.conf

ARG BUILD_MODEL=rock64
RUN echo "$BUILD_MODEL" > /rootfs/etc/hostname
RUN ( echo "127.0.0.1 localhost" && \
      echo "127.0.1.1 $BUILD_MODEL" && \
      echo "" && \
      echo "# The following lines are desirable for IPv6 capable hosts" && \
      echo "::1     localhost ip6-localhost ip6-loopback" && \
      echo "fe00::0 ip6-localnet" && \
      echo "ff00::0 ip6-mcastprefix" && \
      echo "ff02::1 ip6-allnodes" && \
      echo "ff02::2 ip6-allro" ) > /rootfs/etc/hosts

ENTRYPOINT ["make_ext4fs/make_ext4fs"]
