FROM node:12.17.0-buster

ENV TINI_VERSION=v0.19.0 \
    TINI_GPG_KEY=595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    TINI_KILL_PROCESS_GROUP=enabled \
    TINI_SUBREAPER=enabled

RUN echo 'Verifying tini checksum' \
    && curl -L -o /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static \
    && curl -L -o /tini.asc https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static.asc \
    && (gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys ${TINI_GPG_KEY} \
    ||  gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys ${TINI_GPG_KEY}) \
    && gpg --no-tty --verify /tini.asc \
    && chmod +x /tini

ENTRYPOINT ["/tini", "-sg", "--"]

ENV NODE_ENV=development \
    SHELL=/bin/bash \
    TMP_DIR=/mnt/tmp \
    WORKDIR=/app

ENV PATH="${WORKDIR}/bin:${WORKDIR}/node_modules/.bin:${PATH}"

WORKDIR ${WORKDIR}

RUN mkdir ${TMP_DIR} \
    && chown -R node:node ${WORKDIR} ${TMP_DIR}

USER node

# Set custom shell prompt
RUN echo 'export PS1="[DOCKER]:\u@\h:\w\\$ "' >> ~/.bashrc
