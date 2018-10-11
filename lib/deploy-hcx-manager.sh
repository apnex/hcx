#!/bin/bash
ovftool \
	--name=hcx-manager \
	--X:injectOvfEnv \
	--X:logFile=ovftool.log \
	--allowExtraConfig \
	--datastore=datastore1 \
	--network="pg-mgmt" \
	--acceptAllEulas \
	--noSSLVerify \
	--diskMode=thin \
	--prop:mgr_cli_passwd="VMware1!" \
	--prop:mgr_root_passwd="VMware1!" \
	--prop:hostname=hcx-manager \
	--prop:mgr_ip_0=172.16.10.22 \
	--prop:mgr_prefix_ip_0=24 \
	--prop:mgr_gateway_0=172.16.10.1 \
	--prop:mgr_dns_list=172.16.0.1 \
	--prop:mgr_domain_search_list=lab \
	--prop:mgr_ntp_list=8.8.8.8 \
	--prop:mgr_isSSHEnabled=True \
VMware-HCX-Enterprise-3.5.1-9689240.ova \
vi://administrator@vsphere.local:VMware1%21@vcenter.lab/?ip=172.16.0.11
