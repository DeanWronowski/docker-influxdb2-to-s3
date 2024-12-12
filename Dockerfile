FROM influxdb:2.7-alpine
RUN apk add --no-cache bash py3-pip python3-venv && \
    python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --no-cache-dir awscli

COPY influxdb-to-s3.sh /usr/bin/influxdb-to-s3

ENTRYPOINT ["/usr/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
