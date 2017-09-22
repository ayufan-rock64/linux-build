## Binfmt misc allows you to run binaries from other architectures

1. First make sure that you install needed `qemu-user-static`:

```bash
sudo apt-get install -y qemu-user-static
```

2. Make sure that your kernel is recent enough, at least 4.8 which allows to preload architecture dependent files,

3. Add support for binfmts to `/etc/rc.local`.

```
echo -1 > /proc/sys/fs/binfmt_misc/qemu-aarch64 || true
echo -1 > /proc/sys/fs/binfmt_misc/qemu-arm || true
echo ':qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/bin/qemu-aarch64-static:OCF' > /proc/sys/fs/binfmt_misc/register
echo ':qemu-arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:OCF' > /proc/sys/fs/binfmt_misc/register
```

Run `/etc/rc.local` or restart system.

4. Test

```
docker run --rm -it arm64v8/ubuntu:xenial echo Hello World
```

### Why and not `binfmt-support`?

`binfmt-support` does not support `F` flag to preload architecture files,
which is useful when you run container images for different architectures.

Thus, this would not be possible:

```
docker run --rm -it arm64v8/ubuntu:xenial echo Hello World
```
