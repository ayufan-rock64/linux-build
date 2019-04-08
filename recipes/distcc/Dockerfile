FROM ubuntu:bionic

RUN apt-get update -y
RUN apt-get install -y \
  ccache \
  distcc \
  gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

ENTRYPOINT ["distccd"]
CMD ["--daemon", "--no-detach", "-j", "4", "--allow", "0/0"]