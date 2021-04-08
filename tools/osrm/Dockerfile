FROM alpine

LABEL \
  maintainer="Henrique Pettenuci" \
  org.opencontainers.image.title="osrm-backend-alpine" \
  org.opencontainers.image.description="Docker image for the Open Source Routing Machine backend based on Alpine."


ENV OSRM_VERSION 5.22.0

# Install packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk add  git gcc g++ curl ca-certificates cmake python-dev \
                build-base lua5.2 lua5.2-dev boost-dev bzip2-dev \
                py-setuptools pkgconfig libzip-dev py-pip libxml2-dev \
                sparsehash gdal libgomp expat expat-dev libtbb libtbb-dev \
    && pip install -U crcmod \
    && rm -rf /tmp/* /var/tmp/*
 # Build osrm-backend
RUN mkdir /osrm-src \
    && cd /osrm-src \
    && curl --silent -L https://github.com/Project-OSRM/osrm-backend/archive/v$OSRM_VERSION.tar.gz -o v$OSRM_VERSION.tar.gz \
    && tar xzf v$OSRM_VERSION.tar.gz \
    && cd osrm-backend-$OSRM_VERSION \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && cmake --build . \
    && cmake --build . --target install \
    && mkdir /osrm-data \
    && mkdir /osrm-profiles \
    && cp -r /osrm-src/osrm-backend-$OSRM_VERSION/profiles/* /osrm-profiles \
    && rm -rf /osrm-src \
    && cd /tmp

# Set the entrypoint
COPY osrm-entrypoint.sh /
RUN chmod +x /osrm-entrypoint.sh
ENTRYPOINT ["/osrm-entrypoint.sh"]

EXPOSE 5000