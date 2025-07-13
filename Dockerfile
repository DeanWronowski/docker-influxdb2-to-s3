FROM influxdb:2.7-alpine

# Install bash, Python 3 + pip, cron daemon, and AWS-CLI v1
RUN apk add --no-cache bash python3 py3-pip dcron \
 && pip3 install --no-cache-dir awscli

# Copy & make your script executable
COPY influxdb-to-s3.sh /usr/local/bin/influxdb-to-s3
RUN chmod +x /usr/local/bin/influxdb-to-s3

# Use your script as entrypoint; default to daily at midnight
ENTRYPOINT ["/usr/local/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
