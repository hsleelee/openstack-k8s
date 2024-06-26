variable "ca_certificate_lifespan" {
  description = "Lifespan of the ca certificate in days"
  type = number
  default = 3650
}

variable "ca_certificate_early_renewal_window" {
  description = "Window of time before the ca certificate expiry when terrafor should try to renew"
  type = number
  default = 30
}

variable "etcd_ca_certificate_lifespan" {
  description = "Lifespan of the etcd ca certificate in days"
  type = number
  default = 36500
}

variable "etcd_ca_certificate_early_renewal_window" {
  description = "Window of time before the etcd ca certificate expiry when terrafor should try to renew"
  type = number
  default = 30
}

variable "front_proxy_ca_certificate_lifespan" {
  description = "Lifespan of the front proxy ca certificate in days"
  type = number
  default = 3650
}

variable "front_proxy_ca_certificate_early_renewal_window" {
  description = "Window of time before the front proxy ca certificate expiry when terrafor should try to renew"
  type = number
  default = 30
}

variable "client_certificate_lifespan" {
  description = "Lifespan of the client certificate in days"
  type = number
  default = 365
}

variable "client_certificate_early_renewal_window" {
  description = "Window of time before the client certificate expiry when terrafor should try to renew"
  type = number
  default = 30
}

variable "ca_key" {
  description = "Private ca key"
  type = string
}

variable "ca_key_algorithm" {
  description = "Algorith (RSA or ECDSA) used for the ca key"
  type = string
  default = "RSA"
}

variable "etcd_ca_key" {
  description = "Private etcd ca key"
  type = string
}

variable "etcd_ca_key_algorithm" {
  description = "Algorith (RSA or ECDSA) used for the etcd ca key"
  type = string
  default = "RSA"
}

variable "front_proxy_ca_key" {
  description = "Private front proxy ca key"
  type = string
}

variable "front_proxy_ca_key_algorithm" {
  description = "Algorith (RSA or ECDSA) used for the front proxy ca key"
  type = string
  default = "RSA"
}

variable "client_key" {
  description = "Private client key"
  type = string
}

variable "client_key_algorithm" {
  description = "Algorith (RSA or ECDSA) used for the client key"
  type = string
  default = "RSA"
}

variable "legacy_defaults" {
  description = "If set to true, the unspecified subject fields will be set to the defaults of version 3 (empty values) of the tls provider instead of version 4 (omitted)"
  type        = bool
  default     = false
}