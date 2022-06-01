# VAULT POLICY

#### POLICY PRIMER
- https://www.vaultproject.io/docs/concepts/policies

#### READ POLICY
CLI:
```
vault read sys/policy                    
Key         Value
---         -----
keys        [basic-secret-policy cert-manager.crudls default global.crudl root]
policies    [basic-secret-policy cert-manager.crudls default global.crudl root]
```
API:
```
curl \
  --header "X-Vault-Token: ..." \
  https://vault.hashicorp.rocks/v1/sys/policy
```




#### WRITE POLICY
CLI:
```
vault policy write policy-name policy-file.hcl
```
API:
```
curl \
  --request POST \
  --header "X-Vault-Token: ..." \
  --data '{"policy":"path \"...\" {...} "}' \
  https://vault.hashicorp.rocks/v1/sys/policy/policy-name

```

#### EXAMPLE

```
vault policy write pki_test track-files/track-policy.hcl
Success! Uploaded policy: pki_test

vault policy list                                       
basic-secret-policy
cert-manager.crudls
default
global.crudl
pki_test
root

vault read sys/policy/pki_test  
Key      Value
---      -----
name     pki_test
rules    # Enable secrets engine
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# List enabled secrets engine
path "sys/mounts" {
  capabilities = [ "read", "list" ]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
```






#### REFERENCE
- https://www.vaultproject.io/docs/commands/policy
- https://www.vaultproject.io/docs/concepts/policy








