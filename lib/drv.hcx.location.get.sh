#!/bin/bash

VCUSER="administrator@vsphere.local"
VCPASS=$(echo -n "VMware1!" | base64)
#echo "${VCPASS}"

HCXTOKEN=$(echo -n "admin:VMware1!" | base64)
#echo "${HCXTOKEN}"

function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"data": {
			"items": [
				{
					"config": {
						"url": "https://connect.hcx.vmware.com",
						"activationKey": "string"
					}
				}
			]
		}
	}
	CONFIG
	printf "${BODY}"
}


#BODY=$(makeBody)
#echo ${BODY} | jq --tab .

URL="https://172.16.10.22:9443/api/admin/global/config/location"
RESPONSE=$(curl -k -X GET \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic ${HCXTOKEN}" \
	-d "$BODY" \
"${URL}" 2>/dev/null)

echo $RESPONSE | jq --tab .
