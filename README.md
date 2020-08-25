docker-mongo-backups
====================

Uses `mongodump` to dump a mongo DB, encrypts with PGP and uploads to S3.
It does also cleanup old backups.

#### Schedules
It does a backup every
- 15 Minutes to the folder ./latest 
- hour to the folder ./hourly
- day to the folder ./daily

#### Clenup
It removes old backups on s3 in the following way
- latest-backups: older than 3 hours
- hourly-backups: older than a day
- daily-backups: older than 3 months

#### Encryption
The public-key for gpg should be placed inside a directory and mounted as a 
volume into the container.


Restore backup
--------------
1. Run  
   ```mongorestore --host <host> --port <port> --username <username> --password <pq> --drop --archive=<mongo-dump-archive>```  
   Attention: Relative paths (with ~/) for <mongo-dump-archive> do not seem to work.


Example docker-compose declaration
----------------------------------

Paste this into your `compose.yaml` file.

```yaml
services:
  postgres:
    image: jegger/mongo-backups:latest
    volumes:
      - ./config/certs/backupPub.key:/var/gpgkeys/backupPub.key
    environment:
      - 'AWS_ACCESS_KEY_ID=myid'
      - 'AWS_SECRET_ACCESS_KEY=mykey'
      - 'S3_BUCKET_NAME=piplanning1'
      - 'S3_ENDPOINT=https://sos-ch-dk-2.exo.io'
      - 'PREFIX=piserver-mongo-backup'
      - 'MONGO_HOST=localhost'
      - 'MONGO_PORT=2000'
      - 'MONGO_USER=username'
      - 'MONGO_PASSWORD=mypw'
      - 'BUCKET_PATH=mongo'
      - 'GPG_PUBKEY_PATH=/var/gpgkeys/backupPub.key'
```

Building
--------

```
docker build -t jegger/mongo-backups:latest .
docker login
docker push jegger/mongo-backups:latest
```

Run
---
```
docker run -ti \
-e GPG_PUBKEY_PATH='/var/gpgkeys/pub.key' \
-e AWS_ACCESS_KEY_ID='MYKEY' \
-e AWS_SECRET_ACCESS_KEY='MYSECRET' \
-e S3_BUCKET_NAME='piplanning1' \
-e S3_ENDPOINT='https://sos-ch-dk-2.exo.io' \
-e PREFIX='piserver-mongo-backup' \
-e MONGO_HOST='111.222.333.444' \
-e MONGO_PORT='4321' \
-e MONGO_PASSWORD='verySecretPW' \
-e MONGO_USER='someAdminUser' \
-e BUCKET_PATH='mongo' \
-v /Users/user/Downloads:/var/gpgkeys \
-v /Users/user/Downloads/pub.key:/var/gpgkeys/pub.key \
jegger/mongo-backups:latest
```