FROM couchbase:community-4.0.0
MAINTAINER dmytro.kovalov@gmail.com

RUN \
  apt-get update \
  && apt-get install -y python-pip && pip install awscli  \
  && apt-get autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH "/bin:/sbin:/usr/bin:/usr/sbin:/opt/couchbase/bin:/usr/local/bin/:/usr/local/sbin/"

ENTRYPOINT ["/backup_couchbase.sh"]
CMD ["backup"]

COPY backup_couchbase.sh /
