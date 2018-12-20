#!/bin/bash

BACKUP_RATE=$1

# Specify the cleanup times for all the rates
case $BACKUP_RATE in
     daily)
          OLDER_THAN="3 months ago"
          ;;
     hourly)
          OLDER_THAN="1 day ago"
          ;;
     *)
          OLDER_THAN="3 hour ago"
          ;;
esac


echo "cleanup s3:" $BACKUP_RATE ", everything which is older than" $OLDER_THAN "=>" `date --date "$OLDER_THAN" +%s`
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
cmd="aws s3 ls s3://$S3_BUCKET_NAME/$BUCKET_PATH/$BACKUP_RATE/ --endpoint-url $S3_ENDPOINT"
$cmd | while read -r line;
do
  createDate=`echo $line|awk {'print $1" "$2'}`
  createDate=`date -d"$createDate" +%s`
  olderThan=`date --date "$OLDER_THAN" +%s`
  fileName=`echo $line|awk {'print $4'}`
  if [[ $createDate -lt $olderThan ]]
  then
    echo ${createDate} ${olderThan} ${fileName}
    aws s3 rm "s3://$S3_BUCKET_NAME/$BUCKET_PATH/$BACKUP_RATE/$fileName" --endpoint-url "$S3_ENDPOINT"
  fi
done;
echo "end of cleanup s3"