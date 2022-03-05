# REFERENCE

####


#### VAULT PKI API
- https://www.vaultproject.io/api/secret/pki


#### VAULT & POSTGRESQL
- Tutorial (Static):
https://learn.hashicorp.com/tutorials/vault/database-creds-rotation
- Tutorial (Dynamic):
https://learn.hashicorp.com/tutorials/vault/database-secrets
- Postgresql Docker:
https://hub.docker.com/_/postgres

#### VAULT SECRET ENGINE - DATABASE
- https://www.vaultproject.io/docs/secrets/databases/postgresql
- https://learn.hashicorp.com/tutorials/vault/database-secrets
- https://learn.hashicorp.com/tutorials/nomad/vault-postgres?in=vault/cross-products


#### COMMAND

READ PKI ROLE
```
vault read -format=json pki_int/roles/y0y0dyn3-dot-com
```