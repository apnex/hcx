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
function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"username": "${HCXUSER}",
		"password": "${HCXPASS}"
	}
	CONFIG
	printf "${BODY}"
}

BODY=$(makeBody)
URL="https://${HCXHOST}/hybridity/api/sessions"
#echo ${BODY} | jq --tab .

RESPONSE=$(curl -k -D "${STATEDIR}"/hcx.headers.txt -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-d "$BODY" \
"$URL" 2>/dev/null)
#echo $RESPONSE | jq --tab .

# extract token
XHMHEADER="$(grep x-hm-authorization: ${STATEDIR}/hcx.headers.txt)"
if [[ $XHMHEADER =~ ([a-f0-9:]+)[^a-f0-9:]*$ ]]; then
	XHMTOKEN=${BASH_REMATCH[1]}
fi

### POST to create new remote registration
# login
VMCUSER='cloudadmin@vmc.local'
VMCPASS='U$ky2d%yb3'
function cloudBody {
	read -r -d '' BODY <<-CONFIG
	{
		"remote": {
			"username": "$(echo ${VMCUSER})",
			"password": "$(echo ${VMCPASS})",
			"url": "https://hcx.sddc-52-63-255-45.vmwarevmc.com"
		}
	}
	CONFIG
	printf "%s\n" ${BODY}
}

BODY=$(cloudBody)
echo ${BODY}

URL="https://${HCXHOST}/hybridity/api/cloudConfigs"
RESPONSE=$(curl -k -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "x-hm-authorization: ${XHMTOKEN}" \
	-d "${BODY}" \
"${URL}" 2>/dev/null)
echo $RESPONSE | jq --tab .

