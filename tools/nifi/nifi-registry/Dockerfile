# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

FROM openjdk:8-jre
LABEL maintainer="Henrique Pettenuci <hpettenuci@outlook.com>"
LABEL site="https://nifi.apache.org"

ARG UID=1000
ARG GID=1000
ARG NIFI_REGISTRY_BINARY
ARG NIFI_REGISTRY_VERSION=0.6.0
ARG MIRROR=https://downloads.apache.org

ENV NIFI_REGISTRY_BASE_DIR /opt/nifi-registry
ENV NIFI_REGISTRY_HOME ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-current
ENV NIFI_REGISTRY_BINARY_URL=nifi/nifi-registry/nifi-registry-${NIFI_REGISTRY_VERSION}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz

ENV GIT_KEY_DIR /home/nifi/.ssh/
ENV GIT_REPOSITORY ssh://git@gitlab.repository.com:2289/repo.git
ENV NIFI_REGISTRY_FLOW_STORAGE_DIR ${NIFI_REGISTRY_BASE_DIR}/git-nifi-repository

ADD scripts/ ${NIFI_REGISTRY_BASE_DIR}/scripts/
RUN chmod -R +x ${NIFI_REGISTRY_BASE_DIR}/scripts/*.sh

ADD .ssh/ ${GIT_KEY_DIR}

# Setup NiFi Registry user and create necessary directories
RUN groupadd -g ${GID} nifi || groupmod -n nifi `getent group ${GID} | cut -d: -f1` \
    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m nifi \
    && mkdir -p ${NIFI_REGISTRY_BASE_DIR} \
    && echo "StrictHostKeyChecking no\n" >> ${GIT_KEY_DIR}config \
    && chown -R nifi:nifi /home/nifi \
    && chown -R nifi:nifi ${NIFI_REGISTRY_BASE_DIR} \
    && chown -R nifi:nifi ${GIT_KEY_DIR}* \    
    && chmod -R 600 ${GIT_KEY_DIR}id* \
    && apt-get update \
    && apt-get install -y jq xmlstarlet procps git \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* 

USER nifi    

# Download, validate, and expand Apache NiFi Registry binary.
RUN curl -fSL ${MIRROR}/${NIFI_REGISTRY_BINARY_URL} -o ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && echo "$(curl ${MIRROR}/${NIFI_REGISTRY_BINARY_URL}.sha256) *${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz" | sha256sum -c -  \
    && tar -xvzf ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz -C ${NIFI_REGISTRY_BASE_DIR} \
    && rm ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION}-bin.tar.gz \
    && mv ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} ${NIFI_REGISTRY_HOME} \    
    && ln -s ${NIFI_REGISTRY_HOME} ${NIFI_REGISTRY_BASE_DIR}/nifi-registry-${NIFI_REGISTRY_VERSION} 
    
# Web HTTP(s) ports
EXPOSE 18080 18443

WORKDIR ${NIFI_REGISTRY_HOME}

# Apply configuration and start NiFi
#
# We need to use the exec form to avoid running our command in a subshell and omitting signals,
# thus being unable to shut down gracefully:
# https://docs.docker.com/engine/reference/builder/#entrypoint
#
# Also we need to use relative path, because the exec form does not invoke a command shell,
# thus normal shell processing does not happen:
# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
ENTRYPOINT ["../scripts/start.sh"]