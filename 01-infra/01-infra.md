# [INFRA] Set up Vault Infrastructure for PoC

## Prerequisites
- Docker
- Kind
- kubectl
- Vault CLI
- Terraform
- make
- jq
- curl
- PGP / pass
- Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,

## Instantiate Vault (Dev Mode) in Docker Container

```
make -f Makefile.cli.01.vault_infra vault-setup
```

Admin token == ```root```



