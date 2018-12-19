#!/bin/sh

# Load env variables from temporary file
# source /tmp/env.sh
export $(grep -v '^#' /tmp/env.sh | xargs -d '\n')

#set
#set -x

# Credit for lots of this goes to: https://github.com/siomiz/PostgreSQL-S3
set -e # stop if any of these commands fail

echo "*** Starting run-backup.sh ***"

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/tmp/$PREFIX-$DATE.archive"
GPG_FILE="/tmp/$PREFIX-$DATE.archive.gpg"
S3_URI="s3://$S3_BUCKET_NAME/$BUCKET_PATH/$PREFIX-$DATE.archive.gpg.gz"

echo "> Running mongodump"
mongodump --host ${MONGO_HOST} --port ${MONGO_PORT} -u ${MONGO_USER} -p ${MONGO_PASSWORD} --archive=$FILE

echo "> import public key from /var/gpgkeys/"
gpg --import ${GPG_PUBKEY_PATH}

echo "> Encrypting dump file using gpg"
KEYID=`gpg --batch --with-colons ${GPG_PUBKEY_PATH} | head -n1 | cut -d: -f5`
gpg --always-trust -v -e -r ${KEYID} -o $GPG_FILE $FILE

echo "> Zipping dump file"
gzip -9 $GPG_FILE

echo "> Uploading to S3"
AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws s3 cp "$GPG_FILE.gz" "$S3_URI" --endpoint-url "$S3_ENDPOINT" --acl bucket-owner-full-control

# Clean up
echo "> Cleanup local files"
rm $FILE
rm "$GPG_FILE.gz"

echo "> Cleanup S3"
bash /code/cleanup.sh

echo "> Done."
