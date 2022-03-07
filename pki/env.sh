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
