#!/bin/bash

_error() {
    echo "::error file=entrypoint.sh::${1}"
}

_abort_with_error() {
    _error "${1}"
    exit 1
}

_sanity_checks() {
    local REQUIRED_ENV="AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_S3_BUCKET"
    local RETVAL=0
    for R in ${REQUIRED_ENV}; do
        local _v=INPUT_${R}
        if [[ -z ${!_v} ]]; then
            _error "Environment variable ${R} missing"
            ((RETVAL++))
        fi
    done
    return ${RETVAL}
}

_pre() {
	_sanity_checks
    return $?
}

_configure() {
    aws configure --profile s3-deploy-action <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF
    return $?
}

_deploy() {
    aws s3 sync "${INPUT_SRC_DIR:-.}" \
    "s3://${INPUT_AWS_S3_BUCKET}/${INPUT_DST_DIR}" \
    --profile s3-deploy-action
    return $?
}

_run() {
    _pre       || _abort_with_error "Aborted. Failed in _pre()."
    _configure || _abort_with_error "Aborted. Failed in _configure()."
    _deploy    || _abort_with_error "Aborted. Failed in _deploy()."
}

_run
