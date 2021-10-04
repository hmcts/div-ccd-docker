#!/bin/sh

set -eu

USERNAME=${1:-fr_applicant_sol@sharklasers.com}
PASSWORD=${2:-Testing1234}

if [ "${ENVIRONMENT:-local}" == "local" ]; then
  IDAM_API_BASE_URL=${IDAM_STUB_LOCALHOST:-http://localhost:5000}
elif [ "$ENVIRONMENT" == "aat" ]; then
  IDAM_API_BASE_URL=https://idam-api.aat.platform.hmcts.net
else
  echo "Set your ENVIRONMENT variable to 'aat' or 'local'"
fi

curl --show-error --header 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -d "username=${USERNAME}&password=${PASSWORD}" "$IDAM_API_BASE_URL/loginUser" | docker run --rm --interactive stedolan/jq -r .api_auth_token
