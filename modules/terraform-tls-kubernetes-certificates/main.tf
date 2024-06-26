#https://kubernetes.io/docs/setup/best-practices/certificates/

resource "tls_self_signed_cert" "ca" {
  private_key_pem = var.ca_key

  subject {
    common_name  = "kubernetes"
    country = var.legacy_defaults ? "" : null
    locality = var.legacy_defaults ? "" : null
    organization = var.legacy_defaults ? "" : null
    organizational_unit = var.legacy_defaults ? "" : null
    postal_code = var.legacy_defaults ? "" : null
    province = var.legacy_defaults ? "" : null
    serial_number = var.legacy_defaults ? "" : null
    street_address = var.legacy_defaults ? [] : null
  }

  validity_period_hours = var.ca_certificate_lifespan*24
  early_renewal_hours = var.ca_certificate_early_renewal_window*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
  ]

  is_ca_certificate = true
}

resource "tls_self_signed_cert" "etcd_ca" {
  private_key_pem = var.etcd_ca_key

  subject {
    common_name  = "etcd-ca"
    country = var.legacy_defaults ? "" : null
    locality = var.legacy_defaults ? "" : null
    organization = var.legacy_defaults ? "" : null
    organizational_unit = var.legacy_defaults ? "" : null
    postal_code = var.legacy_defaults ? "" : null
    province = var.legacy_defaults ? "" : null
    serial_number = var.legacy_defaults ? "" : null
    street_address = var.legacy_defaults ? [] : null
  }

  validity_period_hours = var.etcd_ca_certificate_lifespan*24
  early_renewal_hours = var.etcd_ca_certificate_early_renewal_window*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
  ]

  is_ca_certificate = true
}

resource "tls_self_signed_cert" "front_proxy_ca" {
  private_key_pem = var.front_proxy_ca_key

  subject {
    common_name  = "front-proxy-ca"
    country = var.legacy_defaults ? "" : null
    locality = var.legacy_defaults ? "" : null
    organization = var.legacy_defaults ? "" : null
    organizational_unit = var.legacy_defaults ? "" : null
    postal_code = var.legacy_defaults ? "" : null
    province = var.legacy_defaults ? "" : null
    serial_number = var.legacy_defaults ? "" : null
    street_address = var.legacy_defaults ? [] : null
  }

  validity_period_hours = var.front_proxy_ca_certificate_lifespan*24
  early_renewal_hours = var.front_proxy_ca_certificate_early_renewal_window*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
  ]

  is_ca_certificate = true
}

resource "tls_cert_request" "client" {
  private_key_pem = var.client_key

  subject {
    common_name  = "kubernetes-admin"
    organization = "system:masters"
    country = var.legacy_defaults ? "" : null
    locality = var.legacy_defaults ? "" : null
    organizational_unit = var.legacy_defaults ? "" : null
    postal_code = var.legacy_defaults ? "" : null
    province = var.legacy_defaults ? "" : null
    serial_number = var.legacy_defaults ? "" : null
    street_address = var.legacy_defaults ? [] : null
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = var.ca_key
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.client_certificate_lifespan*24
  early_renewal_hours = var.client_certificate_early_renewal_window*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
  ]

  is_ca_certificate = false
}