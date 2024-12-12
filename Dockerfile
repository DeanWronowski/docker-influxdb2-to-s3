FROM influxdb:2.7-alpine

RUN apk add --no-cache bash py3-pip py3-virtualenv && \
    virtualenv /venv && \
    source /venv/bin/activate && \
    pip install --no-cache-dir awscli

COPY influxdb-to-s3.sh /usr/bin/influxdb-to-s3

ENTRYPOINT ["/usr/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
