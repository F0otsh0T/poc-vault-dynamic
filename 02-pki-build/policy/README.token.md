# VAULT TOKEN

#### TOKEN CREATE
- https://www.vaultproject.io/docs/commands/token/create

Create Token:
```
vault token create -policy=my-policy -policy=other-policy
Key                Value
---                -----
token              95eba8ed-f6fc-958a-f490-c7fd0eda5e9e
token_accessor     882d4a40-3796-d06e-c4f0-604e8503750b
token_duration     768h
token_renewable    true
token_policies     [default my-policy other-policy]
```








#### EXAMPLE

```
vault token create -policy=pki_test -format=json | jq
{
  "request_id": "5fb3600e-8042-51cf-be4f-23fb2ae1f072",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": null,
  "warnings": null,
  "auth": {
    "client_token": "s.m1w1cfDBU0G0tN5sNzjuuWg1",
    "accessor": "R4KhjzovpNHs6yUucVGj79Ic",
    "policies": [
      "default",
      "pki_test"
    ],
    "token_policies": [
      "default",
      "pki_test"
    ],
    "identity_policies": null,
    "metadata": null,
    "orphan": false,
    "entity_id": "",
    "lease_duration": 2764800,
    "renewable": true
  }
}
```









#### REFERENCE
- https://www.vaultproject.io/docs/commands/token
- https://www.vaultproject.io/docs/concepts/tokens








