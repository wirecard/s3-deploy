FROM python:3.8-alpine

LABEL maintainer="Lukas Deutz <lukas.deutz@wirecard.com>; Herbert Knapp <herbert.knapp@wirecard.com>"
LABEL repository="https://github.com/wirecard/s3-deploy"

LABEL com.github.actions.name="S3 Deploy"
LABEL com.github.actions.description="Deploy to AWS S3 bucket"
LABEL com.github.actions.icon="upload-cloud"
LABEL com.github.actions.color="yellow"

RUN apk add --no-cache bash
RUN pip install awscli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
