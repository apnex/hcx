#!/bin/bash

VCUSER="administrator@vsphere.local"
VCPASS=$(echo -n "VMware1!" | base64)
echo "${VCPASS}"

# this creates the following vcenter/mob Extensions
# com.vmware.hybridity
# com.vmware.hybridity.dr
# com.vmware.hybridity.hcsp-dashboard
# com.vmware.hybridity.publisher
# com.vmware.hybridity.troubleshooting
# com.vmware.hybridity.fleet-deployment-ui
# com.vmware.hybridity.auditlog-ui

function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"data": {
			"items": [
				{
					"config": {
						"url": "https://vcenter.lab",
						"userName": "${VCUSER}",
						"password": "${VCPASS}"
					}
				}
			]
		}
	}
	CONFIG
	printf "${BODY}"
}


BODY=$(makeBody)
echo ${BODY} | jq --tab .

URL="https://172.16.10.22:9443/api/admin/global/config/vcenter"
RESPONSE=$(curl -k -X POST \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic YWRtaW46Vk13YXJlMSE=" \
	-d "$BODY" \
"${URL}" 2>/dev/null)

echo $RESPONSE | jq --tab .
