##############################################################################
#   
############################################################################## 
locals {
  k8_masters_count = 3
  k8_workers_count = 3
  k8_lb_tunnel_count = 1
  k8_lb_count = 1
  dns = {
     bucket_name = "datacentric_folder",
     nameserver_ips = ["10.10.0.235"]  
  }
}

data "openstack_images_image_v2" "coreos40" {
  name        = "ubuntu-22.04-jammy-server-amd64"  #"Fedora-CoreOS-40"
  most_recent = true 
}


# resource "openstack_compute_keypair_v2" "k8" {
#   name = var.keypair_name
# }

module "k8_security_groups" {
  source = "./modules/terraform-openstack-kubernetes-security-groups"
#  namespace = "datacentric"

master_group_name = "datacentric-master-secgrp"
worker_group_name = "datacentric-worker-secgrp"
load_balancer_group_name = "datacentric-load_balancer-secgrp"
load_balancer_tunnel_group_name = "datacentric-load_balancer_tunnel-secgrp"

}

resource "tls_private_key" "k8_server_ssh_rsa" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "local_file" "k8_server_ssh_rsa_pubkey" {
  content         = tls_private_key.k8_server_ssh_rsa.public_key_pem
  filename        = "k8_server_ssh_rsa_pubkey.pem"
  file_permission = "0600"
}

resource "local_file" "k8_server_ssh_rsa_prikey" {
  content         = tls_private_key.k8_server_ssh_rsa.private_key_pem
  filename        = "k8_server_ssh_rsa_prikey.pem"
  file_permission = "0600"
}

resource "tls_private_key" "k8_server_ssh_ecdsa" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "local_file" "k8_server_ssh_ecdsa_pubkey" {
  content         = tls_private_key.k8_server_ssh_ecdsa.public_key_pem
  filename        = "k8_server_ssh_ecdsa_pubkey.pem"
  file_permission = "0600"
}

resource "local_file" "k8_server_ssh_ecdsa_prikey" {
  content         = tls_private_key.k8_server_ssh_ecdsa.private_key_pem
  filename        = "k8_server_ssh_ecdsa_prikey.pem"
  file_permission = "0600"
}

resource "tls_private_key" "k8_tunnel_client_ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "local_file" "k8_tunnel_client_ssh_pubkey" {
  content         = tls_private_key.k8_tunnel_client_ssh.public_key_pem 
  filename        = "k8_tunnel_client_ssh_pubkey.pem"
  file_permission = "0600"
}

resource "local_file" "k8_tunnel_client_ssh_prikey" {
  content         = tls_private_key.k8_tunnel_client_ssh.private_key_pem
  filename        = "k8_tunnel_client_ssh_prikey.pem"
  file_permission = "0600"
}

resource "openstack_compute_servergroup_v2" "k8_masters" {
  name     = "datacentric-k8-master"
  policies = ["soft-anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8_workers" {
  name     = "datacentric-k8-worker"
  policies = ["soft-anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8_lb_tunnel" {
  name     = "datacentric-k8-lb-tunnel"
  policies = ["soft-anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8_lb" {
  name     = "datacentric-k8-lb"
  policies = ["soft-anti-affinity"]
}


resource "openstack_networking_port_v2" "k8_workers" {
  count              = local.k8_masters_count
  name               = "datacentric-k8-workers-${count.index + 1}"
  network_id         = "a0fd76a8-5a65-46e1-9579-7221276cd321" #module.reference_infra.networks.internal.id
  security_group_ids = [
    module.k8_security_groups.worker_security_group.id,
  ]
  admin_state_up     = true
}

resource "openstack_networking_port_v2" "k8_masters" {
  count              = local.k8_workers_count
  name               = "datacentric-k8-masters-${count.index + 1}"
  network_id         = "a0fd76a8-5a65-46e1-9579-7221276cd321" #module.reference_infra.networks.internal.id
  security_group_ids = [module.k8_security_groups.master_security_group.id]
  admin_state_up     = true
}

resource "openstack_networking_port_v2" "k8_lb_tunnel" {
  count              = local.k8_lb_tunnel_count
  name               = "datacentric-k8-lb-tunnel-${count.index + 1}"
  network_id         = "a0fd76a8-5a65-46e1-9579-7221276cd321" #module.reference_infra.networks.internal.id
  security_group_ids = [module.k8_security_groups.load_balancer_tunnel_security_group.id]
  admin_state_up     = true
}

resource "openstack_networking_port_v2" "k8_lb" {
  count              = local.k8_lb_count
  name               = "datacentric-k8-lb-${count.index + 1}"
  network_id         =  "a0fd76a8-5a65-46e1-9579-7221276cd321" #module.reference_infra.networks.internal.id
  security_group_ids = [module.k8_security_groups.load_balancer_security_group.id]
  admin_state_up     = true
}

module "k8_domain" {
  source = "./modules/terraform-openstack-zonefile"
  domain = "datacentric.dev"
  container = local.dns.bucket_name
  dns_server_name = "ns.datacentric.dev"
  a_records = concat([
    for master in openstack_networking_port_v2.k8_masters: {
      prefix = "masters"
      ip = master.all_fixed_ips.0
    }
  ],
  [
    for worker in openstack_networking_port_v2.k8_workers: {
      prefix = "workers"
      ip = worker.all_fixed_ips.0
    } 
  ])
}

module "k8_masters_vms" {
  source = "./modules/terraform-openstack-kubernetes-node"
  count = local.k8_masters_count
  name = "master-${count.index + 1}"
  network_ports = [{id=openstack_networking_port_v2.k8_masters[count.index].id}] 
  server_group = openstack_compute_servergroup_v2.k8_masters
  image_source = {
     image_id = data.openstack_images_image_v2.coreos40.id
     volume_id = ""
  }   
#  image_id = data.openstack_images_image_v2.coreos40.id
  flavor_id = "1af082ad-4893-4641-83be-3e2e297d0451" #var.flavor_id 8-16-200
#  flavor_id = module.reference_infra.flavors.generic_micro.id
  keypair_name = var.keypair_name #openstack_compute_keypair_v2.k8.name
  ssh_host_key_rsa = {
    public = tls_private_key.k8_server_ssh_rsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_rsa.private_key_openssh
  }
  ssh_host_key_ecdsa = {
    public = tls_private_key.k8_server_ssh_ecdsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_ecdsa.private_key_openssh
  }
}

module "k8_workers_vms" {
  source = "./modules/terraform-openstack-kubernetes-node"
  count = local.k8_workers_count
  name = "worker-${count.index + 1}"
  network_ports =  [{ id=openstack_networking_port_v2.k8_workers[count.index].id}] 
#  network_ports = openstack_networking_port_v2.k8_workers[count.index]
  server_group = openstack_compute_servergroup_v2.k8_workers
  image_source = {
     image_id = data.openstack_images_image_v2.coreos40.id
     volume_id = ""
  } 
#  image_id = data.openstack_images_image_v2.coreos40.id
#  flavor_id = module.reference_infra.flavors.generic_medium.id
  flavor_id = var.flavor_id
  keypair_name = var.keypair_name #openstack_compute_keypair_v2.k8.name
  ssh_host_key_rsa = {
    public = tls_private_key.k8_server_ssh_rsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_rsa.private_key_openssh
  }
  ssh_host_key_ecdsa = {
    public = tls_private_key.k8_server_ssh_ecdsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_ecdsa.private_key_openssh
  }
}

module "k8_lb_tunnel_vms" {
  source = "./modules/terraform-openstack-kubernetes-load-balancer"
  count = local.k8_lb_tunnel_count
  name = "lb-tunnel-${count.index + 1}"
  network_port = openstack_networking_port_v2.k8_lb_tunnel[count.index]
  server_group = openstack_compute_servergroup_v2.k8_lb_tunnel
  image_source = {
     image_id = data.openstack_images_image_v2.coreos40.id
     volume_id = ""
  } 
  #image_id = data.openstack_images_image_v2.coreos40.id
  flavor_id = "ca295cf2-64aa-4adf-b5b2-75e8b581f99b" #var.flavor_id
#  flavor_id = module.reference_infra.flavors.generic_micro.id
  keypair_name = var.keypair_name #openstack_compute_keypair_v2.k8.name
  ssh_host_key_rsa = {
    public = tls_private_key.k8_server_ssh_rsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_rsa.private_key_openssh
  }
  ssh_host_key_ecdsa = {
    public = tls_private_key.k8_server_ssh_ecdsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_ecdsa.private_key_openssh
  }
  tunnel = {
    enabled = true
    ssh = {
      user = "tunnel"
      authorized_key = tls_private_key.k8_tunnel_client_ssh.public_key_openssh
    }
  }
  kubernetes = {
    nameserver_ips = local.dns.nameserver_ips
    domain = "datacentric.dev"
    masters = {
      max_count = 7
      api_timeout = "5m"
      api_port = 6443
      max_api_connections = 200
    }
    workers = {
      max_count = 100
      ingress_http_timeout = "5m"
      ingress_http_port = 30000
      ingress_max_http_connections = 200
      ingress_https_timeout = "5m"
      ingress_https_port = 30001
      ingress_max_https_connections = 2000
    }
  }
}

module "k8_lb_vms" {
  source = "./modules/terraform-openstack-kubernetes-load-balancer"
  count = local.k8_lb_count
  name = "lb-${count.index + 1}"
  network_port = openstack_networking_port_v2.k8_lb[count.index]
  server_group = openstack_compute_servergroup_v2.k8_lb
  image_source = {
     image_id = data.openstack_images_image_v2.coreos40.id
     volume_id = ""
  } 
  #flavor_id = module.reference_infra.flavors.generic_micro.id
  flavor_id = "ea6b3d32-79a5-4d2e-a8e9-7ecf121ea7f4" #var.flavor_id
  keypair_name = var.keypair_name #openstack_compute_keypair_v2.k8.name
  ssh_host_key_rsa = {
    public = tls_private_key.k8_server_ssh_rsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_rsa.private_key_openssh
  }
  ssh_host_key_ecdsa = {
    public = tls_private_key.k8_server_ssh_ecdsa.public_key_openssh
    private = tls_private_key.k8_server_ssh_ecdsa.private_key_openssh
  }
  kubernetes = {
    nameserver_ips = local.dns.nameserver_ips
    domain = "datacentric.dev"
    masters = {
      max_count = 7
      api_timeout = "5m"
      api_port = 6443
      max_api_connections = 200
    }
    workers = {
      max_count = 100
      ingress_http_timeout = "5m"
      ingress_http_port = 30000
      ingress_max_http_connections = 200
      ingress_https_timeout = "5m"
      ingress_https_port = 30001
      ingress_max_https_connections = 2000
    }
  }
}
 
 