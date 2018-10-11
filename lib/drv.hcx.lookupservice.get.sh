#!/bin/bash
if [ -z ${WORKDIR} ]; then
	if [[ $0 =~ ^(.*)/[^/]+$ ]]; then
		WORKDIR=${BASH_REMATCH[1]}
	fi
fi
if [ -z ${SDDCDIR} ]; then
	SDDCDIR=${WORKDIR}
fi
STATEDIR="${WORKDIR}/state"
if [ ! -d ${STATEDIR} ]; then
	mkdir ${STATEDIR}
fi

PARAMS=$(cat ${SDDCDIR}/sddc.parameters)
HCXHOST=$(echo "$PARAMS" | jq -r '.endpoints[] | select(.type=="hcx").hostname')
if [[ ! "$HCXHOST" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	if [[ ! "$HCXHOST" =~ [.] ]]; then
		HCXHOST+=".$DOMAIN" #if not an IP or FQDN, append domain
	fi
fi
HCXUSER=$(echo "$PARAMS" | jq -r '.endpoints[] | select(.type=="hcx").username')
HCXPASS=$(echo "$PARAMS" | jq -r '.endpoints[] | select(.type=="hcx").password')
HCXONLINE=$(echo "$PARAMS" | jq -r '.endpoints[] | select(.type=="hcx").online')
HCXSESSION="${STATEDIR}/hcx.x-hm-authorization"
HCXTOKEN=$(echo -n "admin:VMware1!" | base64)

# login body
#function makeBody {
#	read -r -d '' BODY <<-CONFIG
#	{
#		"username": "${HCXUSER}",
#		"password": "${HCXPASS}"
#	}
#	CONFIG
#	printf "${BODY}"
#}

#BODY=$(makeBody)
#echo "${BODY}" | jq --tab .

#URL="https://${HCXHOST}/hybridity/api/sessions"
#RESPONSE=$(curl -k -D "${STATEDIR}"/hcx.headers.txt -X POST \
#	-H "Accept: application/json" \
#	-H "Content-Type: application/json" \
#	-d "${BODY}" \
#"$URL" 2>/dev/null)
#echo $RESPONSE | jq --tab .

# extract token
#XHMHEADER="$(grep x-hm-authorization: ${STATEDIR}/hcx.headers.txt)"
#if [[ $XHMHEADER =~ ([a-f0-9:]+)[^a-f0-9:]*$ ]]; then
#	XHMTOKEN=${BASH_REMATCH[1]}
#fi

### POST to create new remote registration
#{
#	"remote": {
#		"username": "username@vsphere.local",
#		"password": "password",
#		"url": "https://HCX_CLOUD_IP/"
#	}
#}

# login body
function setBody {
	read -r -d '' BODY <<-CONFIG
	{
		"data": {
			"items": [
				{
					"config": {
						"lookupServiceUrl": "https://vcenter.lab:443/lookupservice/sdk",
						"providerType": "PSC"
					}
				}
			]
		}
	}
	CONFIG
	printf "${BODY}"
}
#BODY=$(setBody)
#echo "${BODY}" | jq --tab .

URL="https://${HCXHOST}:9443/api/admin/global/config/lookupservice"
#	-H "x-hm-authorization: ${XHMTOKEN}" \
RESPONSE=$(curl -k -X GET \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic ${HCXTOKEN}" \
"${URL}" 2>/dev/null)

echo $RESPONSE | jq --tab .
