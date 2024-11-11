FROM debian:stretch-slim

RUN groupadd -r particl && useradd -r -m -g particl particl

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget \
	&& rm -rf /var/lib/apt/lists/*

ENV PARTICL_VERSION 23.2.7.0
ENV PARTICL_URL https://github.com/particl/particl-core/releases/download/v23.2.7.0/particl-23.2.7.0-x86_64-linux-gnu.tar.gz
ENV PARTICL_SHA256 b32c6ec5d9b17edf0c61eb003ce1d46fab4ef3b85828922d2df57f877be3461b

# install particl binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO particl.tar.gz "$PARTICL_URL" \
	&& echo "$PARTICL_SHA256 particl.tar.gz" | sha256sum -c - \
	&& tar -xzvf particl.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV PARTICL_DATA /data
RUN mkdir "$PARTICL_DATA" \
	&& chown -R particl:particl "$PARTICL_DATA" \
	&& ln -sfn "$PARTICL_DATA" /home/particl/.particl \
	&& chown -h particl:particl /home/particl/.particl
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 51735 51738 51935 51938 51936 11938
CMD ["particld"]
