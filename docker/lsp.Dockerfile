FROM ruby:3.2-alpine

ARG VERSION
ENV WORKDIR /app
ENV PLATFORMOS_CHECK_DEBUG true
ENV PLATFORMOS_CHECK_DEBUG_LOG_FILE /tmp/platformos-check-debug.log

RUN apk add --update bash git openssh build-base && mkdir $WORKDIR

WORKDIR $WORKDIR

RUN git clone https://github.com/Platform-OS/platformos-lsp.git && \
  cd platformos-lsp && \
  bundle install && \
  gem build && gem install platformos-check-$VERSION.gem

RUN adduser --disabled-password --gecos '' platformos && chown platformos:platformos -R /app

ENTRYPOINT ["/app/platformos-lsp/bin/platformos-check-language-server"]

USER platformos
