FROM influxdb:2.7-alpine

# 1) Install bash, python3, pip, busybox cron, and awscli (v1 via pip)
RUN apk add --no-cache bash python3 py3-pip busybox-cron \
 && pip3 install --no-cache-dir awscli

# 2) Copy your backup script
COPY influxdb-to-s3.sh /usr/local/bin/influxdb-to-s3
RUN chmod +x /usr/local/bin/influxdb-to-s3

# 3) Entrypoint + default cron schedule
ENTRYPOINT ["/usr/local/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
