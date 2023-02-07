    #! /bin/bash
    HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemtl start nginx
    sudo systemtl enable nginx
    echo "<h1>Welcome to Grandpas Whiskey $HOSTNAME</h1>" | sudo tee /var/www/html/index.html

    sudo apt install awscli -y
    ACCESS_LOG_FILE=/var/log/nginx/access.log
    BUCKET_NAME=whiskey-log-bucket-noabm
    echo "0 * * * * aws s3 cp $ACCESS_LOG_FILE s3://$BUCKET_NAME" > /var/spool/cron/root
    service nginx restart




