# README

---

### POLICY
Write Policy HCL File

```
tee pki_test.hcl <<EOF
# Enable secrets engine
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
EOF
```
OR
```
cat <<EOF > pki_test.hcl
# Enable secrets engine
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
EOF
```
Create ```policy```
```
vault policy write pki_test pki_test.hcl
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


---

### TOKEN
Create ```token``` with new ```pki_test``` ```policy```
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

---

### PKI SECRETS ENGINE
Enable PKI Secrets Engine
```
vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
```

Tune PKI Secrets Engine
```

vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
```

Create internal root certificate
[IGNORE NEXT CODE BLOCK - SHOULD HAVE DONE IT THIS WA]

```
vault write -format=json pki/root/generate/internal common_name="y0y0dyn3.com" ttl=87600h | jq > track-files/ca_root.all.json
cat track-files/ca_root.all.json | jq -r '.data.certificate' > CA_cert.crt
```

```
vault write -field=certificate pki/root/generate/internal common_name="y0y0dyn3.com" ttl=87600h > track-files/CA_cert.crt
```

```
cat track-files/CA_cert.crt 
-----BEGIN CERTIFICATE-----
MIIDODCCAiCgAwIBAgIURrJ7R6Ir+WEhRjZuiiFJ4HI4FYkwDQYJKoZIhvcNAQEL
BQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjE4NTAxMloXDTMy
MDIyODE4NTA0MVowFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv1x6NfRmpbsdJY1jwhgBb2SVHbX63yan5t9H
OxM5ZJZcswxD4WEHsROhRRCLJtn/45posZ4DhCXcobrHh2TSMh+Fl1ZGI9uWlErc
ClODvEadg/VcddV0fMDI7Y7WfYjwtGROOtcJn8sELqaFMI9bV5npdhEKSROJAQ8f
IWRftE/OZTX0VeaxbwPDLp8v4dTeKEEU6ZA/yEt32iFGawjUHPPDnyMmGvl8Mz/T
eJMW0dXQxoolWxUyHov8XHNUg6iGY/ODFKiWj9J6ZDFkuq27vbGWZOnYEzw2BGvl
OSNUqUTTb9vJ/5qIAt47eCe8p6UB+e4lUZ58tag5pmk47xYBmwIDAQABo3wwejAO
BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU0/x4qoJX
XKtdMkxaWy6NKiUsBL8wHwYDVR0jBBgwFoAU0/x4qoJXXKtdMkxaWy6NKiUsBL8w
FwYDVR0RBBAwDoIMeTB5MGR5bjMuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQAUYm9/
hsn0MtRWxSCm7OErnriarKmbWzZ3QQhuIgzg3ukYreb9KrjBqKjX2scsAZsAUETi
HGYHjNs2e95rjA8wDFYU1gHY7xGQfK1KJ23eMiKxrY94Y6yT/sYLfzqGh12i7Mwl
QodW6PUlBdbq8E0vIrkWB5KEBffwzF4wSERAPfGZo4gplQgK3Q/1jTG5Gs/oBCEq
h4hV9rvMs9hqphVhSW2uiDymHk7JrxubFpWsNm5W4BnxcDFcIHvvqh1SgeplEKz3
osdMZbcgTHNIF+3jZZ+gyEjLLgTahHtl45kW8MXq2ZY4X+MgEZRi3QR7MbEMc7w7
GGc6q1KW/qLG3jtJ
-----END CERTIFICATE-----
```

Configure the CA and CRL URLs (Substitute 127.0.0.1:8200 with your Vault Service URL)
```
vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl" 
Success! Data written to: pki/config/urls
```

---

### INTERMEDIATE PKI ENGINE AND CA
PKI Secrets Engine @ ```pki_int```
```
vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
```
```
vault secrets tune -max-lease-ttl=43800h pki_int
Success! Tuned the secrets engine at: pki_int/
```

Generate Intermediate Certificate Signing Request (CSR)
```
vault write -format=json pki_int/intermediate/generate/internal \
        common_name="y0y0dyn3.com Intermediate Authority" \
        | jq -r '.data.csr' > track-files/pki_intermediate.csr 
```
```
cat track-files/pki_intermediate.csr 
-----BEGIN CERTIFICATE REQUEST-----
MIICczCCAVsCAQAwLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0
ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn
n4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet
ZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm
07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw
G6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f
Oxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a
Pirw2xdJ7wOnzgetAgMBAAGgADANBgkqhkiG9w0BAQsFAAOCAQEAMhDq8mF1e3oN
tnW1hBKC9GhvTUFv8HmIcJjBXR5w5BNckziP8IlyUSpc2p8GaoeFy1ki944ubp9v
DAItmkA7uaARaTED5i2jXX6SW7jF/+nXaQ5pJVz29EYMCoJ3RcqGUanAcfjdP+QJ
zehTyr93fJgTlm9nEfHwARenQFRdGpdh1rqBDjh/gGnAzlgmVUk1us9oTmmF6A7a
yzhAkABjL+xmQXwjWRuSjWRrcZza+FDQqja87eJJ3KtBAlcOLg/N3/yUaIFKrF3g
X+/utNsrP/VJq5na7xm6E0AZJJ37klwmc9iTzO7+3FJKbfhKyiHYGeel8mAtLOd1
am4KER1SzA==
-----END CERTIFICATE REQUEST-----
```

Sign the intermediate CSR with the root certificate and save the generated certificate as ```pem```
```
vault write -format=json pki/root/sign-intermediate csr=@track-files/pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' \
        > track-files/intermediate.cert.pem
```
```
cat track-files/intermediate.cert.pem 
-----BEGIN CERTIFICATE-----
MIIDqDCCApCgAwIBAgIULr/3udJvIAOmvdG6/Mi64bhYjPQwDQYJKoZIhvcNAQEL
BQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjIyMzA1NVoXDTI3
MDMwMTIyMzEyNVowLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0
ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn
n4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet
ZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm
07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw
G6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f
Oxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a
Pirw2xdJ7wOnzgetAgMBAAGjgdQwgdEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFAwLRR/L7Ep2oboraRXAOU9II0jvMB8GA1UdIwQY
MBaAFNP8eKqCV1yrXTJMWlsujSolLAS/MDsGCCsGAQUFBwEBBC8wLTArBggrBgEF
BQcwAoYfaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAxBgNVHR8EKjAo
MCagJKAihiBodHRwOi8vMTI3LjAuMC4xOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG
9w0BAQsFAAOCAQEAs9Px4a0+80uo0L2RV0ef3t2BbcN9Fxn7RQkXPnvRW3hIGq9e
DWmmH4CfabWCHe9F/bp7+pUPelW1XAAYIL/DInvqLEniFf3RDIJcWU6ZomFsWR1a
WjaC1zdgAutht7CuP5tefohfzx9zKXHbZWcw8Suq2GXx619Bfb75PCwqEHw22HIe
H++yTC/NImdI6Lcbkd/LCtlYlB7wOdj9kiyZyF75/IztVQtbda11UhpuqwRUjJ6B
H2RlhpPorKtpqCU9J5HyYk2hmtJ27H/k7X19Fs9rkJoNUErZxsfyb4dvo8R9xmjh
oiijYaTWfLB0hhIBMl7PEEVTSQMYBVAdL1Yp4w==
-----END CERTIFICATE-----
```

Import Signed Certificate into VAULT Intermediate PKI Engine ```pki_int```
```
vault write pki_int/intermediate/set-signed \
    certificate=@track-files/intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
```

---

### PKI Role and Intermediate Certificate Issuance
Create ```y0y0dyn3-dot-com``` PKI Role
```
vault write pki_int/roles/y0y0dyn3-dot-com \
  allowed_domains="y0y0dyn3.com" \
  allow_subdomains=true \
  max_ttl="720h"
Success! Data written to: pki_int/roles/y0y0dyn3-dot-com
```

Request new certificate for ```test.y0y0dyn3.com``` domain based on the ```y0y0dyn3-dot-com``` PKI role
```
vault write pki_int/issue/y0y0dyn3-dot-com common_name="test.y0y0dyn3.com" ttl="24h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDqDCCApCgAwIBAgIULr/3udJvIAOmvdG6/Mi64bhYjPQwDQYJKoZIhvcNAQEL
BQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjIyMzA1NVoXDTI3
MDMwMTIyMzEyNVowLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0
ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn
n4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet
ZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm
07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw
G6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f
Oxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a
Pirw2xdJ7wOnzgetAgMBAAGjgdQwgdEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFAwLRR/L7Ep2oboraRXAOU9II0jvMB8GA1UdIwQY
MBaAFNP8eKqCV1yrXTJMWlsujSolLAS/MDsGCCsGAQUFBwEBBC8wLTArBggrBgEF
BQcwAoYfaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAxBgNVHR8EKjAo
MCagJKAihiBodHRwOi8vMTI3LjAuMC4xOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG
9w0BAQsFAAOCAQEAs9Px4a0+80uo0L2RV0ef3t2BbcN9Fxn7RQkXPnvRW3hIGq9e
DWmmH4CfabWCHe9F/bp7+pUPelW1XAAYIL/DInvqLEniFf3RDIJcWU6ZomFsWR1a
WjaC1zdgAutht7CuP5tefohfzx9zKXHbZWcw8Suq2GXx619Bfb75PCwqEHw22HIe
H++yTC/NImdI6Lcbkd/LCtlYlB7wOdj9kiyZyF75/IztVQtbda11UhpuqwRUjJ6B
H2RlhpPorKtpqCU9J5HyYk2hmtJ27H/k7X19Fs9rkJoNUErZxsfyb4dvo8R9xmjh
oiijYaTWfLB0hhIBMl7PEEVTSQMYBVAdL1Yp4w==
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDaTCCAlGgAwIBAgIUXb/07Jngk+E1F4/vGIZHMRzsLcgwDQYJKoZIhvcNAQEL
BQAwLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0ZSBBdXRob3Jp
dHkwHhcNMjIwMzAyMjI1NzAxWhcNMjIwMzAzMjI1NzMwWjAcMRowGAYDVQQDExF0
ZXN0LnkweTBkeW4zLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AMHWbAnrsi3pBtXA656FRAQsOInlCInVK0oIHhQaTiSMalCKtaCSCCpDe2xC0qXa
y3647NOfZ/oczl6FnQWsn5Z4BW9e76emx4y1BmlfGeugdsVxfNYCVYInkdLd+IV8
OJ2mumqFpQh2L3yxDfI/NUQJB9iI2HqMV0vNPzpZ16lmlrUH7q5tCU1+TmTk7Bly
d6T1LEjUEVdk5ovv2blrsiTYR7uJZp08pO7dpaHnTRJNcnmN88uLINnqH+xqvPOz
td1pbPBPSb/Iacw3WDo1h0kjfJ/nQYJyCaIStKbMCPOVo7WpAK58P37HFm26IaVL
YliFsfhyMK18ZTmrZq7WiFMCAwEAAaOBkDCBjTAOBgNVHQ8BAf8EBAMCA6gwHQYD
VR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBS+r2TRWTnQODMK
kC37kBX6jTISHjAfBgNVHSMEGDAWgBQMC0Ufy+xKdqG6K2kVwDlPSCNI7zAcBgNV
HREEFTATghF0ZXN0LnkweTBkeW4zLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAL/Hx
2ljH7wcRnz0sri6Uapo9I6UCOKKl8ZSjWB8EGlSBjF3tUAD7skwyungN5A9Do9sX
hcCpUn+odIKdMGZ0ETgYId9jsqxVVBCyUJEgvP9SE9hItrpTQMWmKS1vRml25lPu
6lk5mJUvWmvcsIJIwvmEilGGvhyKsVb5huA5iuldd16Ke83b0dwlEDKhdi+/uYR1
MekiKmZZDr2ALE/lX7W4Pi1pcgw+0COdZ4h+1xWbjKcA5T3l137RmPctwP9GRi3O
hsHy1k6439vRp/+I7ulVhoR1UO0qhlR4hUTEs6tVm08nToQOq19AicEES8BK3ggn
s8PxjA6P2iWZZXdBlA==
-----END CERTIFICATE-----
expiration          1646348250
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDqDCCApCgAwIBAgIULr/3udJvIAOmvdG6/Mi64bhYjPQwDQYJKoZIhvcNAQEL
BQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjIyMzA1NVoXDTI3
MDMwMTIyMzEyNVowLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0
ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn
n4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet
ZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm
07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw
G6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f
Oxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a
Pirw2xdJ7wOnzgetAgMBAAGjgdQwgdEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFAwLRR/L7Ep2oboraRXAOU9II0jvMB8GA1UdIwQY
MBaAFNP8eKqCV1yrXTJMWlsujSolLAS/MDsGCCsGAQUFBwEBBC8wLTArBggrBgEF
BQcwAoYfaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAxBgNVHR8EKjAo
MCagJKAihiBodHRwOi8vMTI3LjAuMC4xOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG
9w0BAQsFAAOCAQEAs9Px4a0+80uo0L2RV0ef3t2BbcN9Fxn7RQkXPnvRW3hIGq9e
DWmmH4CfabWCHe9F/bp7+pUPelW1XAAYIL/DInvqLEniFf3RDIJcWU6ZomFsWR1a
WjaC1zdgAutht7CuP5tefohfzx9zKXHbZWcw8Suq2GXx619Bfb75PCwqEHw22HIe
H++yTC/NImdI6Lcbkd/LCtlYlB7wOdj9kiyZyF75/IztVQtbda11UhpuqwRUjJ6B
H2RlhpPorKtpqCU9J5HyYk2hmtJ27H/k7X19Fs9rkJoNUErZxsfyb4dvo8R9xmjh
oiijYaTWfLB0hhIBMl7PEEVTSQMYBVAdL1Yp4w==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAwdZsCeuyLekG1cDrnoVEBCw4ieUIidUrSggeFBpOJIxqUIq1
oJIIKkN7bELSpdrLfrjs059n+hzOXoWdBayflngFb17vp6bHjLUGaV8Z66B2xXF8
1gJVgieR0t34hXw4naa6aoWlCHYvfLEN8j81RAkH2IjYeoxXS80/OlnXqWaWtQfu
rm0JTX5OZOTsGXJ3pPUsSNQRV2Tmi+/ZuWuyJNhHu4lmnTyk7t2loedNEk1yeY3z
y4sg2eof7Gq887O13Wls8E9Jv8hpzDdYOjWHSSN8n+dBgnIJohK0pswI85WjtakA
rnw/fscWbbohpUtiWIWx+HIwrXxlOatmrtaIUwIDAQABAoIBAFAvipwEA76YQnqU
hyQZjwyG2pC4zXJvW6wRdZftVdwqtiRBbWdSYcxSBDHB5vAzdbEjgNz+eX3vArP5
Y/6f7ZjKZ70tschR5wTfMhrO+6MMy3VcQD8r0gG4qstnhdJ6k9UrzrwYMzAv6+8S
M2m+GiPd9H/wBFWVztsNuhVCa0Oo8qjXM9drbsatCCSI3HkRL1JLBdTjhmfP3pO9
sEggdgpJXfIHuSv8inmaG6iHH84DK4puvO3ymhw1xJBcJUV4kYepMqDDXs1NwH/I
4ddbh2KMl6HOenUGYd0Z1zUJp4wLiGWTcK9g5W42nqnQv1CW5R1sj439lcfaJvPb
pf+aTnECgYEA8+9pxXau5IUXgnWk2S8EAOjqHjmQWejGubJnxcPrcWSq7toEZHdk
5dv0bKbt2YoZggVFbNbRNUYTnCFaXOjUWQJ4Wa/WwGu/suckW1EDYtv4Ijk8fsn9
2EUyE5fPr+iEKxIfkGfYajFUs4sGnlRsaZXsljYC/MmEYV8RrJ45ghsCgYEAy2yy
lDwoyYmP/LqZFJGizQH0Ef+AWFdge4xuAa4DVZo7kM5apY5Kbr5pnxZZyqh/PUFR
kd/o2/E1SJO7kvhp4vUveDaQxTnkOtdtCWRQs4A7+t2pk+r+Fca2rpJ3dxVLPL40
WSl5vVhwBtpvXTFUnHbtepPXzRzJMz8cqP19NikCgYEAwXxiamVEPjCvQCSueDKJ
u2sD4KuKKzavAjZXh49qnkvaJZC6sTHez1ATZWdW/BlFOFOUCMuvr9EA1vPBqDZp
0Jxb98+4yHHu4SnkNaZhyDVwcTzzFiKD/dqM6OueqgoFY+CBNtqX10t/wtYAju+p
+moX+eGnpvj0zwNIkqICPYcCgYBCgjhktMKVGe/ErnFsQy1aH6Bf3gxlVbQK0OAK
lo0qiLGe54jFhh8Z1BGOXO1gj/SB34A+1Fk6x8MnBn4WUDe2Z3lssVJl2UagYlyY
7H5iIbP6kkxmOzd1gTGrI+IBQioGIx3UZPYTjP2bkAFHE+DZAx0jrYCp5BZ4NdM2
ASLV+QKBgB9Ea6K+1ourO9yWGUDcBkPpKk2wg1NgQQf/hEZAOJwTS33qnO1O0MhK
Iey9dicAzVUXnUkSDvAaz4bUE7RXgxhHOAIOb4GtmYGOGvNbJ5grKrTA++zv8bhT
88EBLourj1QAJhr3uqBzkNmB9TAaI+vT9LhcWyEZwmeQHssjISqG
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       5d:bf:f4:ec:99:e0:93:e1:35:17:8f:ef:18:86:47:31:1c:ec:2d:c8
```

JSON Format
```
vault write pki_int/issue/y0y0dyn3-dot-com common_name="test.y0y0dyn3.com" ttl="24h" -format=json | jq > track-files/intermediate.json
{
  "request_id": "1230cb47-73b7-97ad-e5ca-be723b4a21c3",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "ca_chain": [
      "-----BEGIN CERTIFICATE-----\nMIIDqDCCApCgAwIBAgIULr/3udJvIAOmvdG6/Mi64bhYjPQwDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjIyMzA1NVoXDTI3\nMDMwMTIyMzEyNVowLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0\nZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn\nn4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet\nZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm\n07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw\nG6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f\nOxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a\nPirw2xdJ7wOnzgetAgMBAAGjgdQwgdEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB\n/wQFMAMBAf8wHQYDVR0OBBYEFAwLRR/L7Ep2oboraRXAOU9II0jvMB8GA1UdIwQY\nMBaAFNP8eKqCV1yrXTJMWlsujSolLAS/MDsGCCsGAQUFBwEBBC8wLTArBggrBgEF\nBQcwAoYfaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAxBgNVHR8EKjAo\nMCagJKAihiBodHRwOi8vMTI3LjAuMC4xOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG\n9w0BAQsFAAOCAQEAs9Px4a0+80uo0L2RV0ef3t2BbcN9Fxn7RQkXPnvRW3hIGq9e\nDWmmH4CfabWCHe9F/bp7+pUPelW1XAAYIL/DInvqLEniFf3RDIJcWU6ZomFsWR1a\nWjaC1zdgAutht7CuP5tefohfzx9zKXHbZWcw8Suq2GXx619Bfb75PCwqEHw22HIe\nH++yTC/NImdI6Lcbkd/LCtlYlB7wOdj9kiyZyF75/IztVQtbda11UhpuqwRUjJ6B\nH2RlhpPorKtpqCU9J5HyYk2hmtJ27H/k7X19Fs9rkJoNUErZxsfyb4dvo8R9xmjh\noiijYaTWfLB0hhIBMl7PEEVTSQMYBVAdL1Yp4w==\n-----END CERTIFICATE-----"
    ],
    "certificate": "-----BEGIN CERTIFICATE-----\nMIIDaTCCAlGgAwIBAgIUFmpKXfhRmbhPX9BXIRsCD78XbgUwDQYJKoZIhvcNAQEL\nBQAwLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0ZSBBdXRob3Jp\ndHkwHhcNMjIwMzAyMjMwMzQ2WhcNMjIwMzAzMjMwNDE2WjAcMRowGAYDVQQDExF0\nZXN0LnkweTBkeW4zLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB\nAMp4+KXboyoHdwlQTdEJCJbZiB9rpt8r084IIiEbw3r9NKHY5E3BUN66c8uTgwoD\na39cjJiVVf/Ax09ALkwkbZ81vkC7m+web1ehxjUYHS570ABMqdJERWE6745SSvR/\nOJPTtVhoVUkUMl1z1lmgt/XB2CLh/7POLStrkcDofCcnJjGt1LSOJKXYJsrkSdwv\n+TEZcMJRVVfDtL//uEO6wyIn/Z9ykheSiR2r2Vmt8TvSrffIhsMpVi6uUcwTs9ts\nrLhNeQGdm19up8vf0SlLxP+xJcaLYSjQo1mfB+QatEcg6EVBNylDfTSGuZnqr9tG\nLTnEWN9s7BDyoKWwffotCTcCAwEAAaOBkDCBjTAOBgNVHQ8BAf8EBAMCA6gwHQYD\nVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBRNx8EAppCAB1OA\n3vdBzkrRslOH3DAfBgNVHSMEGDAWgBQMC0Ufy+xKdqG6K2kVwDlPSCNI7zAcBgNV\nHREEFTATghF0ZXN0LnkweTBkeW4zLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAUwZt\n+OQTK2wudUOrLpVkih969vHFzY58APRdTguASpjkFs0O7yM9FV8w8X/uLzWB6vvC\nV+K/XoYjFe0z5tAC3BSrMjiF9jWt+So+HNg8PXBzbcGBf9bAAz+oUudBXI5aQSg2\n6g/C/+wHccijnbxdgKgobwvDogePjPbLr2wXVy37vjYKTTpMEx+bugibH7UTg5cl\n4ZMudS/npu8jeTuvg3+cgw3w8SuNH33M2gWnBZG2FU7iaq9fMe5p2eLU7ioujR3B\nlUPpWjIqSym+0U4LpVOtiJ9rVev6DkqZG+2IQvfjr+DBr598mWkTzLTw00OgjFN2\nANT1zEF+84CSF/Fpbg==\n-----END CERTIFICATE-----",
    "expiration": 1646348656,
    "issuing_ca": "-----BEGIN CERTIFICATE-----\nMIIDqDCCApCgAwIBAgIULr/3udJvIAOmvdG6/Mi64bhYjPQwDQYJKoZIhvcNAQEL\nBQAwFzEVMBMGA1UEAxMMeTB5MGR5bjMuY29tMB4XDTIyMDMwMjIyMzA1NVoXDTI3\nMDMwMTIyMzEyNVowLjEsMCoGA1UEAxMjeTB5MGR5bjMuY29tIEludGVybWVkaWF0\nZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDK+yhn\nn4I/0TOeq9pnm1lgE4wtLnMM6hvEvtUgg5p4EWY0zwnbZRwlP9zdEtJPIptkxdet\nZgEKlRTjcUcHTWz23Qeokd7VL6Xui9S2rZ9iCPnMcaRZ5ZqhL5ivBNtvNm6ZaJRm\n07aPppTZlVCH6DhXuilXPLwzHsB70yzSi9wP9h/HjmAv9xBBa37fE02qFY1V2PZw\nG6w6YA5MSUjVRwa4eBSOFTj424epYBW5x3K+qhU7KoOvt98kaNHD9Abcedv8v63f\nOxu12s46ndRxi7EOLRgaQYPOMMpyNwqLIJB9DEPfTzAxsnc4+dJIryG+5zdDOG7a\nPirw2xdJ7wOnzgetAgMBAAGjgdQwgdEwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB\n/wQFMAMBAf8wHQYDVR0OBBYEFAwLRR/L7Ep2oboraRXAOU9II0jvMB8GA1UdIwQY\nMBaAFNP8eKqCV1yrXTJMWlsujSolLAS/MDsGCCsGAQUFBwEBBC8wLTArBggrBgEF\nBQcwAoYfaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAxBgNVHR8EKjAo\nMCagJKAihiBodHRwOi8vMTI3LjAuMC4xOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG\n9w0BAQsFAAOCAQEAs9Px4a0+80uo0L2RV0ef3t2BbcN9Fxn7RQkXPnvRW3hIGq9e\nDWmmH4CfabWCHe9F/bp7+pUPelW1XAAYIL/DInvqLEniFf3RDIJcWU6ZomFsWR1a\nWjaC1zdgAutht7CuP5tefohfzx9zKXHbZWcw8Suq2GXx619Bfb75PCwqEHw22HIe\nH++yTC/NImdI6Lcbkd/LCtlYlB7wOdj9kiyZyF75/IztVQtbda11UhpuqwRUjJ6B\nH2RlhpPorKtpqCU9J5HyYk2hmtJ27H/k7X19Fs9rkJoNUErZxsfyb4dvo8R9xmjh\noiijYaTWfLB0hhIBMl7PEEVTSQMYBVAdL1Yp4w==\n-----END CERTIFICATE-----",
    "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAynj4pdujKgd3CVBN0QkIltmIH2um3yvTzggiIRvDev00odjk\nTcFQ3rpzy5ODCgNrf1yMmJVV/8DHT0AuTCRtnzW+QLub7B5vV6HGNRgdLnvQAEyp\n0kRFYTrvjlJK9H84k9O1WGhVSRQyXXPWWaC39cHYIuH/s84tK2uRwOh8JycmMa3U\ntI4kpdgmyuRJ3C/5MRlwwlFVV8O0v/+4Q7rDIif9n3KSF5KJHavZWa3xO9Kt98iG\nwylWLq5RzBOz22ysuE15AZ2bX26ny9/RKUvE/7ElxothKNCjWZ8H5Bq0RyDoRUE3\nKUN9NIa5meqv20YtOcRY32zsEPKgpbB9+i0JNwIDAQABAoIBABBuxwd3DwQPPQsF\neHtZt1e+6fxa2V1NilAzesmjHjdyK35jQwxIf07EZTeFjmIWqvfYRBTyMdujAsoc\n1GUbo8YDL6DDWUFNqw26tIKEpYGrTNNpZXMKVXMxvFWZujmjxazBxvsY5Ksct4W8\nLA50K9oHVIpoOz+VoTbf8SFt/P2UW6Ic7F/ySC7m8pDiMmU16wXNPl1e3yiH/f8g\noCjs9jrtvUL0UeifrnDL7UKNXhaLorYH9F9i0j4pYzs7+EymHFTz7sCT5Cuh16ze\ndoBTS9vQH20hKPT7rMcH6YHK4sEiyjrtCtXeHrPuqoTW1kjonVjo/54ZnqlSDx/u\nduFyLYkCgYEA/5jDfLGVx7tsRrNeqqJYEWPqfZqbdFp9pseEkJa2vqaExf1ULbSY\nla/zrlK6Cc8EyYKoEkgqWEllWSq2fvlXo+IxiwVAHHzfZQ9ugFxaRSFD9cTfL5zV\n0FN4m7lRL5fCSIc5Vkn3tt7/uFLxOd7PMoMc9W8N+J+YXVT41b6yyl0CgYEAysrA\nKLTrvy/doW+Difs2RqE6fivWlNRO7t+ReSHeLisSDNAaNiMUkDYEHQvtkXheXUc6\nO5+QpigbOrrpPL8e2pS8mX6GLVQk7Zvy3Ky02P/H8q13V+YkzfwO0DGy61gJatyg\nv6rWT8n7jXQmmamK8NJcFrdNWNqsTVOf/I8r8KMCgYB9LvK/xbJYKqFzVzKMXArK\nKaeVcP2mVROpdZqlvksuwRvSZKqv3/3DgnPU80uOtkff8hAjNBkZOIlczKCpO7IC\n4CvnrOCjkz1On+o9D/5eUVaZrpypEyVdbSRrEK6Eos1S/HfGnV+nvzx7qJPhBhFw\n6eprAsNS+8eCHrXo6gdjOQKBgBniSSao+RI9HM/XOPXqr6HSQHIMTGZQtwZ8WMga\nT46bBsHF6iKQ1bYWfu3qMNeJgpnrVn53vnHG2rrjUpPjXR/PLkd1Q9ETVWdSqWwL\nS0YLV80c4QfCI157VrSyM0EgyoruQEJWnuYuRMJoWejxH//fCcwId4Ho32c7Tkdh\nSt17AoGAHZ0GdUPVwEYuXrJsiIInacn01j3Z3e2D2JsUTUNLAN+1rSaEoghey81n\nVkMLnHmWw17u9wmzs72IxAbUs8phWT7BPuBTNAWd6HVgf2oP/lVnl/xj8zWSa189\nRLEmgXnJXuOttOnRD331+IFyNiTpEWn3YwyFlL6xua5RK3wGTjI=\n-----END RSA PRIVATE KEY-----",
    "private_key_type": "rsa",
    "serial_number": "16:6a:4a:5d:f8:51:99:b8:4f:5f:d0:57:21:1b:02:0f:bf:17:6e:05"
  },
  "warnings": null
}

```









