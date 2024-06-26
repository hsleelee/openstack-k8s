# About

This terraform module will generate the top level (main, etcd, front proxy) ca certificates as well as a client certificate (signed with the main certificate) in a way that is compliant with what kubernetes expect.

# Motivation

Most kubernetes installation methods will automatically generate all private keys and certificates that kubernetes use to authentify its tls traffic.

Sometimes, you may need to access (or even manage) those certificates outside of kubernetes and extracting them from an existing kubernetes installation can be a pain.

It can be simpler to generate the certificates outside of kubernetes and then pass them to the kubernetes installation (which many installation methods support).

# Input Variables

- **ca_certificate_lifespan**: How long in days the main ca certificate should last before it expires (defaults to 3650 which is roughtly 10 years).
- **ca_certificate_early_renewal_window**: How long in days should terraform wait before the expiry of the main ca certicate to trigger its renewal (defaults to 30)
- **etcd_ca_certificate_lifespan**: How long in days the etcd ca certificate should last before it expires (defaults to 36500 which is roughtly 100 years).
- **etcd_ca_certificate_early_renewal_window**: How long in days should terraform wait before the expiry of the etcd ca certicate to trigger its renewal (defaults to 30)
- **front_proxy_ca_certificate_lifespan**: How long in days the front proxy ca certificate should last before it expires (defaults to 3650 which is roughtly 10 years).
- **front_proxy_ca_certificate_early_renewal_window**: How long in days should terraform wait before the expiry of the front proxy ca certicate to trigger its renewal (defaults to 30)
- **client_certificate_lifespan**: How long in days the client certificate should last before it expires (defaults to 365 which is roughtly a year).
- **client_certificate_early_renewal_window**: How long in days should terraform wait before the expiry of the client certicate to trigger its renewal (defaults to 30)
- **ca_key**: The private key that should be used to generate the main ca certificate.
- **ca_key_algorithm**: The algorithm of the main ca private key (can be **RSA** or **ECDSA**, defaults to **RSA**)
- **etcd_ca_key**: The private key that should be used to generate the etcd ca certificate.
- **etcd_ca_key_algorithm**: The algorithm of the etcd ca private key (can be **RSA** or **ECDSA**, defaults to **RSA**)
- **front_proxy_ca_key**: The private key that should be used to generate the front proxy ca certificate.
- **front_proxy_ca_key_algorithm**: The algorithm of the front proxy ca private key (can be **RSA** or **ECDSA**, defaults to **RSA**)
- **client_key**: The private key that should be used to generate the client certificate.
- **client_key_algorithm**: The algorithm of the client private key (can be **RSA** or **ECDSA**, defaults to **RSA**)
- **legacy_defaults**: If set to true, the unspecified subject fields will be set to the defaults of version 3 (empty values) of the tls provider instead of version 4 (omitted). Defaults to false.

# Output Variables

- **ca_certificate**: The main ca certificate as a string in pem format
- **etcd_ca_certificate**: The etcd ca certificate as a string in pem format
- **front_proxy_ca_certificate**: The front proxy ca certificate as a string in pem format
- **client_certificate**: The client certificate as a string in pem format

# Usage Example

```
resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "tls_private_key" "etcd_ca" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "tls_private_key" "front_proxy_ca" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "tls_private_key" "client" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

module "certificates" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-tls-kubernetes-certificates.git"
  ca_key = tls_private_key.ca.private_key_pem
  etcd_ca_key = tls_private_key.etcd_ca.private_key_pem
  front_proxy_ca_key = tls_private_key.front_proxy_ca.private_key_pem
  client_key = tls_private_key.client.private_key_pem
}
```