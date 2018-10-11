#!/bin/bash

RESPONSE=$(curl -k -X GET \
	-H "accept: application/json" \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "authorization: Basic YWRtaW46Vk13YXJlMSE=" \
"https://172.16.10.22:9443/api/admin/global/config/vcenter" 2>/dev/null)

echo $RESPONSE | jq --tab .
