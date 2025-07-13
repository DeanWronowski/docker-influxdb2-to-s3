FROM influxdb:2.7-alpine

RUN apk add --no-cache bash python3 py3-pip dcron \
 && pip3 install --no-cache-dir --break-system-packages awscli

COPY influxdb-to-s3.sh /usr/local/bin/influxdb-to-s3
RUN chmod +x /usr/local/bin/influxdb-to-s3

ENTRYPOINT ["/usr/local/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
