FROM mongo:4.0.4-xenial
MAINTAINER Dominique Burnand <youwillfind@me.com>

USER root
RUN apt-get update
RUN apt-get install -q -y --force-yes \
  cron \
  gnupg \
  python-pip \
  gzip

# AWS Command Line Interface
RUN pip install awscli==1.9.15

# Note that because cron does not seem to know about Docker's environment
# variables, we have to read them in from a file that we write out
# in entrypoint.sh at runtime.
#RUN echo "* * * * * env - \`cat /tmp/env.sh\` /bin/bash -c '(sh /code/run-backup.sh) >> /code/backups-cron.log 2>>\&1'" | crontab -
RUN echo "* * * * * sh /code/run-backup.sh >> /code/backups-cron.log" | crontab -

#RUN crontab -l

RUN mkdir -p /code
WORKDIR /code
ADD entrypoint.sh /code/entrypoint.sh
ADD run-backup.sh /code/run-backup.sh
ADD cleanup.sh /code/cleanup.sh
RUN chmod +x /code/entrypoint.sh
RUN chmod +x /code/cleanup.sh

ENTRYPOINT ["sh", "entrypoint.sh"]
CMD [""] # overrides the default from image we inherited from
