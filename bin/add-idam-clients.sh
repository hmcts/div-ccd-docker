#!/usr/bin/env bash

set -eu

IDAM_URI="http://localhost:5000"

REDIRECTS=("http://localhost:3001/oauth2/callback" "https://div-pfe-aat.service.core-compute-aat.internal/authenticated" "http://localhost:3000/oauth2/callback")
REDIRECTS_STR=$(printf "\"%s\"," "${REDIRECTS[@]}")
REDIRECT_URI="[${REDIRECTS_STR%?}]"

CCD_REDIRECTS=("http://ccd-data-store-api/oauth2redirect")
CCD_REDIRECTS_STR=$(printf "\"%s\"," "${CCD_REDIRECTS[@]}")
CCD_REDIRECT_URI="[${CCD_REDIRECTS_STR%?}]"

DIV_CLIENT_ID="divorce"
XUI_CLIENT_ID="xuiwebapp"


ROLES_ARR=("citizen" "claimant" "ccd-import" "caseworker-divorce" "caseworker" "caseworker-divorce-courtadmin_beta" "caseworker-divorce-systemupdate" "caseworker-divorce-superuser" "caseworker-divorce-pcqextractor" "caseworker-divorce-courtadmin-la" "caseworker-divorce-bulkscan" "caseworker-divorce-courtadmin" "caseworker-divorce-solicitor" "caseworker-caa" "payment")
ROLES_STR=$(printf "\"%s\"," "${ROLES_ARR[@]}")
ROLES="[${ROLES_STR%?}]"

XUI_ROLES_ARR=("XUI-Admin" "XUI-SuperUser" "caseworker" "caseworker-divorce" "caseworker-divorce-courtadmin_beta" "caseworker-divorce-superuser" "caseworker-divorce-courtadmin-la" "caseworker-divorce-courtadmin" "caseworker-divorce-solicitor" "caseworker-caa" "payment")
XUI_ROLES_STR=$(printf "\"%s\"," "${XUI_ROLES_ARR[@]}")
XUI_ROLES="[${XUI_ROLES_STR%?}]"

AUTH_TOKEN=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=idamOwner@hmcts.net&password=Ref0rmIsFun" | docker run --rm --interactive stedolan/jq -r .api_auth_token)
HEADERS=(-H "Authorization: AdminApiAuthToken ${AUTH_TOKEN}" -H "Content-Type: application/json")

dir=$(dirname ${0})

${dir}/utils/idam-create-service.sh "ccd_gateway" "ccd_gateway" "ccd_gateway_secret" "http://localhost:3451/oauth2redirect" "false" "profile openid roles"

${dir}/utils/idam-create-service.sh "xui_webapp" "xui_webapp" "xui_webapp_secrect" "http://localhost:3455/oauth2/callback" "false" "profile openid roles manage-user create-user"

echo "Setup ccd data store client"
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "ccd_data_store_api", "label": "ccd_data_store_api", "oauth2ClientId": "ccd_data_store_api", "oauth2ClientSecret": "idam_data_store_client_secret", "oauth2RedirectUris": '${CCD_REDIRECT_URI}', "oauth2Scope": "profile openid roles manage-user", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'
