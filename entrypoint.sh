#!/bin/bash

_error() {
    echo "::error file=entrypoint.sh::$1"
}

_pre() {
    if [[ -z $INPUT_AWS_ACCESS_KEY_ID ]]; then
        _error "AWS_ACCESS_KEY_ID not provided."
    fi
    if [[ -z $INPUT_AWS_SECRET_ACCESS_KEY ]]; then
        _error "AWS_SECRET_ACCESS_KEY not provided."
    fi
    if [[ -z $INPUT_AWS_REGION ]]; then
        _error "AWS_REGION not provided."
    fi
    if [[ -z $INPUT_AWS_S3_BUCKET ]]; then
        _error "AWS_S3_BUCKET not provided."
    fi
}

_configure() {
    echo -n "aws installed here: "
    which aws
    aws configure --profile s3-deploy-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF
}

_deploy() {
    aws s3 sync "${INPUT_SRC_DIR:-.}" \
    "s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DST_DIR}" \
    --profile s3-deploy-actions
}

_run() {
    _pre
    _configure
    _deploy
}

_run
