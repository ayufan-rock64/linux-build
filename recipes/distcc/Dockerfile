FROM ubuntu:bionic

RUN apt-get update -y
RUN apt-get install -y \
  ccache \
  distcc \
  gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

ENTRYPOINT ["distccd"]
CMD ["--daemon", "--log-stderr", "--stats", "--no-detach", "--jobs", "6", "--allow", "0.0.0.0/0"]
EXPOSE 3632
EXPOSE 3633
