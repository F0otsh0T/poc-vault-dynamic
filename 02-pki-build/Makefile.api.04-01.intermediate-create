################################################################################
# VAULT PKI API - PKI_INT CREATE & PROCESS INTERMEDIATE CERTIFICATE
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - Docker
#   - Kind
#   - kubectl
#   - Vault CLI
#   - Terraform
#   - make
#   - jq
#   - curl
#   - PGP/GPG/PASS
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

################################################################################
# ALL
################################################################################
all: cert-create cert-format cert-list cert-read #target


##########
# GENERATE INTERMEDIATE CERTIFICATE
#
cert-create: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request POST --data @body/cert-create.json ${VAULT_ADDR}/v1/pki_int/issue/y0y0dyn3-dot-com > workspace/tmp/intermediate.json

##########
# FORMAT INTERMEDIATE CERTIFICATE FOR CLIENT CONSUMPTION
#
cert-format: #target
	touch workspace/tmp/server.bundle
	cat workspace/tmp/intermediate.json | jq -r '.data.certificate' > workspace/tmp/server.certificate
	cat workspace/tmp/intermediate.json | jq -r '.data.private_key' > workspace/tmp/server.private_key
	cat workspace/tmp/intermediate.json | jq -r '.data.issuing_ca' > workspace/tmp/server.issuing_ca
	cat workspace/tmp/intermediate.json | jq -r '.data.serial_number' > workspace/tmp/server.serial_number
	cp workspace/tmp/server.bundle workspace/tmp/server.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
#	cat workspace/tmp/server.certificate workspace/tmp/server.private_key workspace/tmp/server.issuing_ca > workspace/tmp/server.bundle
#	cat workspace/tmp/server.certificate workspace/tmp/server.issuing_ca > workspace/tmp/server.bundle
	cat workspace/tmp/server.certificate workspace/tmp/server.issuing_ca workspace/tmp/ca_root.issuing_ca > workspace/tmp/server.bundle

##########
# LIST CERTS
#
cert-list: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request LIST ${VAULT_ADDR}/v1/pki/certs | jq
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request LIST ${VAULT_ADDR}/v1/pki_int/certs | jq

##########
# READ CERT
#
cert-read: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request GET ${VAULT_ADDR}/v1/pki_int/cert/$(shell cat workspace/tmp/server.serial_number) | jq


