# Create docker image used for provisioning Apache NiFi Registry into Alpine-based linux container

FROM alpine:3.12.0
LABEL io.qabsu.description="Apache NiFi Registry container provisioned on Alpine Linux"
LABEL io.qabsu.maintainer="qabsu.io"
LABEL io.qabsu.organisation="qabsu pty limited"
LABEL io.qabsu.contributor="grant priestley"
LABEL io.qabsu.email="grant.priestley@qabsu.io"
LABEL io.qabsu.url="https://www.qabsu.io/"

# set container arguments
ARG NIFI_REGISTRY_VERSION=0.8.0
## set path for binaries from mirror, sha256 from backup site
ARG NIFI_REGISTRY_BINARY=https://apache.mirror.digitalpacific.com.au/nifi/nifi-registry/nifi-registry-$NIFI_REGISTRY_VERSION/nifi-registry-$NIFI_REGISTRY_VERSION-bin.tar.gz
ARG NIFI_REGISTRY_BINARY_SHA=https://downloads.apache.org/nifi/nifi-registry/nifi-registry-$NIFI_REGISTRY_VERSION/nifi-registry-$NIFI_REGISTRY_VERSION-bin.tar.gz.sha256
ARG UID=1000
ARG GID=1000

# set container environment variables
ENV NIFI_REGISTRY_BASE_DIR=/opt/nifi-registry
ENV NIFI_REGISTRY_HOME ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-current

# execute operating system tasks
## copy the scripts an make them executable
COPY scripts/* ${NIFI_REGISTRY_BASE_DIR}/scripts/
RUN chmod -R +x ${NIFI_REGISTRY_BASE_DIR}/scripts/*.sh
## create necessary group & user, as well as requred directories with correct ownership
RUN addgroup -g ${GID} nifi \
    && adduser --shell /bin/bash -S nifi -u ${UID} -G nifi \
    && mkdir -p ${NIFI_REGISTRY_BASE_DIR} \
    && chown -R nifi:nifi ${NIFI_REGISTRY_BASE_DIR}
## install apline linux operating system dependencies for Apache NiFi
RUN apk --update add bash git tar curl ca-certificates sudo openssh rsync xmlstarlet openjdk8 \
    && rm -rf /var/cache/apk/*

# set container user
USER nifi

# install binaries
## fetch, validate and install Apache NiFi
RUN curl -fSL ${NIFI_REGISTRY_BINARY} -o ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && echo "$(curl ${NIFI_REGISTRY_BINARY_SHA}) *${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz" | sha256sum -c - \
    && tar -xvzf ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz -C ${NIFI_REGISTRY_BASE_DIR} \
    && rm ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && mv ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} ${NIFI_REGISTRY_HOME} \
    && ln -s ${NIFI_REGISTRY_HOME} ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} \
    && chown -R nifi:nifi ${NIFI_REGISTRY_HOME}

# set the container volumes
VOLUME ${NIFI_REGISTRY_HOME}/conf

# configure the exposed ports of the container
EXPOSE 18080 18443

# set working directory
WORKDIR ${NIFI_REGISTRY_HOME}

# apply configuration and start Apache NiFi
ENTRYPOINT ["../scripts/start.sh"]