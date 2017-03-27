FROM alpine:3.4

RUN apk add --no-cache \
    bash \
    curl \
    git \
    gcc \
    make \
    python \
  && git clone --depth 1 https://github.com/sstephenson/bats.git /tmp/bats && \
     /tmp/bats/install.sh /usr/local && rm -rf /tmp/bats

ARG NAMESPACE
ENV \
  HOME="/$NAMESPACE/home"

# register executing user's uid and gid at runtime [alternative to briceburg/nss_wraper]
RUN chmod o+w /etc/passwd /etc/group && \
  printf "#!/usr/bin/env sh\n\
  echo \"$NAMESPACE:x:\$(id -u):$(id -g):gecos:$HOME:/bin/sh\" >> /etc/passwd\n\
  echo \"$NAMESPACE:x:\$(id -g):\" >> /etc/group\n\
  exec \$@\n" > /entrypoint.sh && chmod +x /entrypoint.sh

VOLUME $HOME
WORKDIR /$NAMESPACE

ENTRYPOINT ["/entrypoint.sh"]
CMD bats tests/bats/


RUN apk add --update libc-dev

RUN apk add linux-headers
