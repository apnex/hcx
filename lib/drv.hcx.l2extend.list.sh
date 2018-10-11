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

# login
#		"username": "${HCXUSER}",
#		"password": "${HCXPASS}"
function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"username": "administrator@vsphere.local",
		"password": "VMware1!"
	}
	CONFIG
	printf "${BODY}"
}


BODY=$(makeBody)
URL="https://172.16.10.22/hybridity/api/sessions"
echo ${BODY} | jq --tab .

RESPONSE=$(curl -k -D state/hcx.headers.txt -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-d "$BODY" \
"$URL" 2>/dev/null)
echo $RESPONSE | jq --tab .

# extract token
TOKEN="$(grep x-hm-authorization: state/hcx.headers.txt)"
REGEX='([a-f0-9:]+)[^a-f0-9:]*$'
if [[ $TOKEN =~ $REGEX ]]; then
	NEW=${BASH_REMATCH[1]}
fi

### POST to create new remote registration
#{
#	"remote": {
#		"username": "username@vsphere.local",
#		"password": "password",
#		"url": "https://HCX_CLOUD_IP/"
#	}
#}

RESPONSE=$(curl -k -X GET \
	-H "x-hm-authorization: ${NEW}" \
	-H "Accept: application/json" \
"https://172.16.10.22/hybridity/api/l2Extensions" 2>/dev/null)
echo $RESPONSE | jq --tab .

