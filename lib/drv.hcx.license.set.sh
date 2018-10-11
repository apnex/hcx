#!/bin/bash

VCUSER="administrator@vsphere.local"
VCPASS=$(echo -n "VMware1!" | base64)
#echo "${VCPASS}"

HCXTOKEN=$(echo -n "admin:VMware1!" | base64)

function makeBody {
	local LICENSE=${1}
	read -r -d '' BODY <<-CONFIG
	{
		"data": {
			"items": [
				{
					"config": {
						"url": "https://connect.hcx.vmware.com",
						"activationKey": "${LICENSE}"
					}
				}
			]
		}
	}
	CONFIG
	printf "${BODY}"
}


BODY=$(makeBody "${1}")
echo ${BODY} | jq --tab .

URL="https://172.16.10.22:9443/api/admin/global/config/hcx"
RESPONSE=$(curl -k -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic ${HCXTOKEN}" \
	-d "$BODY" \
"${URL}" 2>/dev/null)

echo $RESPONSE | jq --tab .
