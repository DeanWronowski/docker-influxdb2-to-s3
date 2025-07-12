FROM influxdb:2.7-alpine

# Install python3, pip and aws-cli globally
RUN apk add --no-cache bash py3-pip \
 && pip3 install --no-cache-dir awscli

COPY influxdb-to-s3.sh /usr/bin/influxdb-to-s3
RUN chmod +x /usr/bin/influxdb-to-s3

ENTRYPOINT ["/usr/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
