#!/bin/bash

VCUSER="administrator@vsphere.local"
VCPASS=$(echo -n "VMware1!" | base64)
echo "${VCPASS}"

HCXPASS=$(echo -n "admin:VMware1!" | base64)
echo "${HCXPASS}"

function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"city": "Melbourne",
		"country": "Australia",
		"cityAscii": "Melbourne",
		"latitude": -37.82003131,
		"longitude": 144.9750162
	}
	CONFIG
	printf "${BODY}"
}


BODY=$(makeBody)
echo ${BODY} | jq --tab .

URL="https://172.16.10.22:9443/api/admin/global/config/location"
RESPONSE=$(curl -k -X PUT \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic ${HCXPASS}" \
	-d "${BODY}" \
"${URL}" 2>/dev/null)

echo $RESPONSE | jq --tab .
