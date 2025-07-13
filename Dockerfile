FROM influxdb:2.7-alpine

RUN apk add --no-cache bash curl unzip \
 && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
 && unzip /tmp/awscliv2.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/awscliv2.zip /tmp/aws

# rest of your Dockerfile unchanged
COPY influxdb-to-s3.sh /usr/local/bin/influxdb-to-s3
RUN chmod +x /usr/local/bin/influxdb-to-s3

ENTRYPOINT ["/usr/local/bin/influxdb-to-s3"]
CMD ["cron", "0 0 * * *"]
