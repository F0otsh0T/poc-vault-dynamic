# VAULT SECRETS ENGINE: PKI

## INTRODUCTION
We will be utilizing some Open Source Software (OSS) tools like ```make``` to abstract and organize the steps for this demo and ```PGP/GPG/PASS``` to store and pass sensitive data like secrets ;-) This is an attempt to make this example modular, consumable, and the Client codified and immutable.

## PREREQUISITES
   - Docker
   - Kind
   - kubectl
   - Vault CLI
   - Terraform
   - make
   - jq
   - curl
   - PGP/GPG/PASS
   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,

## SHELL ENVIRONMENT
Depending on your Vault Application (K8s, Docker, HCP), you will need to set your shell ```environment``` variables for the following (E.g. @ ```pki/env.sh```:

```
#!/bin/sh

set -o xtrace

## VAULT_SKIP_VERIFY
#export VAULT_SKIP_VERIFY=true
#unset VAULT_SKIP_VERIFY

## VAULT_TOKEN
#export VAULT_TOKEN=''
#unset VAULT_TOKEN

## VAULT_NAMESPACE: Vault Enterprise
#export VAULT_NAMESPACE=admin
#unset VAULT_NAMESPACE

## VAULT_ADDR
#export VAULT_ADDR='https://:8200'
#export VAULT_ADDR='https://CHANGE_ME.aws.hashicorp.cloud:8200'
#export VAULT_ADDR='http://0.0.0.0:8200'
#export VAULT_ADDR='https://0.0.0.0:8200'
#export VAULT_ADDR='http://127.0.0.1:8200'
#export VAULT_ADDR='https://127.0.0.1:8200'
#export VAULT_ADDR='https://127.0.0.1:8201'
#export VAULT_ADDR='https://:8200'
#unset VAULT_ADDR

## VAULT_FORMAT
#export VAULT_FORMAT=json
#unset VAULT_FORMAT

## VAULT_TOKEN
#export VAULT_TOKEN=$(pass vault/pki_test)
#unset VAULT_TOKEN
```
**OR**
```
export VAULT_ADDR=$(pass vault/local-url)
export VAULT_TOKEN=$(pass vault/local-token)
```
```
export VAULT_ADDR=$(pass vault/hcp-url)
export VAULT_TOKEN=$(pass vault/hcp-token)
export VAULT_NAMESPACE=admin
```

^^ Note: ```GPG/PGP/Pass``` locations above depends on where you have stored your local Secrets - This is just a little tidiness to keep the credentials from being stored in shell history

Utilizing ```GPG/PGP/Pass``` to store and pass sensitive information throughout this demo. ```Makefiles``` will be utilized to organize and run the steps from the ```pki``` (most of the VAULT PKI activity) and ```pki/workspace``` (Docker Build & Run activity) directories. The above VAULT environment variables will be important to set properly for this demo to function.

## VAULT

You can spin up a Vault environment via a number of different ways:
- Hashicorp Cloud Platform (HCP): https://learn.hashicorp.com/collections/vault/cloud
- Install binaries: https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
- Docker: ```Makefile``` @ ```infra/Makefile.cli.01.vault_infra```
  ```
  cd infra
  make -f Makefile.cli.01.vault_infra vault-setup
  
  ```

## OPTIONAL: CREATE POLICY

```
cd pki
make -f Makefile.cli.02-01.policy create-policy
vault policy list | jq

```

## OPTIONAL: CREATE NEW AUTH TOKEN WITH ABOVE POLICY
```
make -f Makefile.cli.02-02.auth_token auth-token
make -f Makefile.cli.02-02.auth_token vault-login
vault token lookup -format=json | jq

```

## VAULT: PKI ENGINE - CA ROOT
```
make -f Makefile.cli.03-01.pki pki-enable
make -f Makefile.cli.03-01.pki pki-ca_root_create
make -f Makefile.cli.03-01.pki pki-ca_crl

```

## VAULT: PKI_INT ENGINE - INTERMEDIATE CA
```
make -f Makefile.cli.03-02.pki_int pki_int-enable
make -f Makefile.cli.03-02.pki_int pki_int-csr
make -f Makefile.cli.03-02.pki_int pki_int-csr_sign
make -f Makefile.cli.03-02.pki_int pki_int-cert_import
make -f Makefile.cli.03-02.pki_int pki_int-ca_crl
make -f Makefile.cli.03-02.pki_int pki_int-role_create

```

## VAULT: CREATE INTERMEDIATE CERTIFICATE
```
make -f Makefile.cli.04-01.intermediate-create cert-create
make -f Makefile.cli.04-01.intermediate-create cert-format
make -f Makefile.cli.04-01.intermediate-create cert-list
make -f Makefile.cli.04-01.intermediate-create cert-read

```

## VAULT CLIENT: NGINX - BUILD IMAGE
"IMMUTABLE": We will build the PKI data into the container for this demo but other methods exist to inject or consume PKI into the service:
- Vault Agent Inject / Sidecar
- K8s Auth / JWT Inject (```mutatingwebhook```)
- K8s ```configmap```
- certmanager
- Container volume mounts
- etc.,

```
cd pki/workspace
make -f Makefile.docker_build build
docker image ls | grep -i pkiclient

```

## VAULT CLIENT: NGINX - RUN
```
terraform init
terraform plan
terraform apply

```
^^ Input "yes"

```
docker ps | grep -i pkiclient

```

## WEB BROWSER TEST
Open up your web browser and open up the web page @:
- https://127.0.0.1:9000
- ``CN`` URL as declared in the Intermediate Certificate create process - you may need to create a host entry to point to the IP of where the Docker service for Nginx resides.
- Import CA Cert as "TRUSTED" in your Web Browser









