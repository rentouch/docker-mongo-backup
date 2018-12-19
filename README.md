docker-mongo-backups
====================

Uses `mongodump` to dump a mongo DB, encrypts with PGP and
uploads to S3. Runs a backup every 60 minutes.

The public-key for gpg should be placed inside a directory and mounted as a 
volume into the container.

(This is some sort of fork of: https://github.com/rentouch/docker-postgres-backups)

Example docker-compose declaration
----------------------------------

Paste this into your `compose.yaml` file.

```yaml
postgres_backups:
  image: jegger/mongo-backups:latest
  environment:
    AWS_ACCESS_KEY_ID: my-aws-key
    AWS_SECRET_ACCESS_KEY: my-aws-secret
    S3_BUCKET_NAME: my-backups
    S3_ENDPOINT: https://sos-ch-dk-2.exo.io  # Allows non Amazon endpoints
    PREFIX: postgres-backup # S3 key prefix to save with
    MONGO_HOST: my-postgres-service-name
    MONGO_PORT: 4321  # Port to postgres
    MONGO_PASSWORD: postgres
    MONGO_USER: postgres
    GPG_PUBKEY_PATH: /var/gpgkeys/pub.key # path to PGP public key
  volumes:
    /local/path/to/key:/var/gpgkeys
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
-e OLDER_THAN='5 minutes ago' \
-v /Users/user/Downloads:/var/gpgkeys \
-v /Users/user/Downloads/pub.key:/var/gpgkeys/pub.key \
jegger/mongo-backups:latest
```