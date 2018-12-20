set -e # stop if any of these commands fail

: ${GPG_PUBKEY_PATH:?"-e GPG_PUBKEY_PATH is not set"}
: ${AWS_ACCESS_KEY_ID:?"-e AWS_ACCESS_KEY_ID is not set"}
: ${AWS_SECRET_ACCESS_KEY:?"-e AWS_SECRET_ACCESS_KEY is not set"}
: ${S3_BUCKET_NAME:?"-e S3_BUCKET_NAME is not set"}
: ${PREFIX:?"-e PREFIX is not set"}

# Write out runtime ENV vars so that we can source them in our script.
# (cron is not aware of those)
env > /tmp/env.sh

echo "run job once"
sh /code/run-backup.sh

echo "Starting cron daemon..."
cron
touch /code/backups-cron.log
tail -f /code/backups-cron.log
