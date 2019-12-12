#!/bin/bash

_error() {
    echo "::error file=entrypoint.sh::$1"
}

_sanity_checks() {
    local REQUIRED_ENV="AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_S3_BUCKET"
    local RETVAL=0
    for R in ${REQUIRED_ENV}; do
        local _v=INPUT_${R}
        if [[ -z ${!_v} ]]; then
            echo "Environment variable ${R} missing"
            ((RETVAL++))
        fi
    done
    return ${RETVAL}
}

_pre() {
	_sanity_checks
    if [[ $? -gt 0 ]]; then
        echo "Sanity Checks failed. Aborting deployment."
        exit 1
    fi
}

_configure() {
    aws configure --profile s3-deploy-action <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF
}

_deploy() {
    aws s3 sync "${INPUT_SRC_DIR:-.}" \
    "s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DST_DIR}" \
    --profile s3-deploy-action
}

_run() {
    _pre
    _configure
    _deploy
}

_run
