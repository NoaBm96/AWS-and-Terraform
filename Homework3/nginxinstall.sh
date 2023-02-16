#!/bin/bash

sudo apt update
sudo apt install nginx awscli -y

sed -i "s/nginx/Welcome to Grandpa's Whiskey $(hostname)/g" /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
    
echo "set_real_ip_from ${module.vpc_module.vpc_cidr};" >> /etc/nginx/conf.d/default.conf; echo "real_ip_header    X-Forwarded-For;" >> /etc/nginx/conf.d/default.conf

service nginx restart

# Upload web server access logs to S3 every hour-
echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://opsschool-nginx-access-log" > /var/spool/cron/crontabs/root




