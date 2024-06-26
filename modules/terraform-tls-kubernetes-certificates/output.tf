output "ca_certificate" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "etcd_ca_certificate" {
  value = tls_self_signed_cert.etcd_ca.cert_pem
}

output "front_proxy_ca_certificate" {
  value = tls_self_signed_cert.front_proxy_ca.cert_pem
}

output "client_certificate" {
  value = tls_locally_signed_cert.client.cert_pem
}