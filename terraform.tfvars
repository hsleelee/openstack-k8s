server_group={
    id          = "d27ee6b9-ef1a-4462-b8d1-0c08b5c5541e" 
  }

# os image c6bb9bb8-bbaa-473a-a744-370293bfa35b
image_source = {image_id="67ccb087-dcda-4067-98b1-cac7fa1ad0ea",volume_id=""}

#ID of the flavor the bastion will run on or name
flavor_id = "139da05c-8fed-423e-a1e1-edaf734834c5"
#flavor_name = ""

#Network port to assign to the node. Should be of type openstack_networking_port_v2
network_ports =  [{
    id          = "509fc214-3087-4ff5-955c-98534baa5863"
#    id          = "a0fd76a8-5a65-46e1-9579-7221276cd321"
#    subnet_id   = "5416e561-e2f3-4a7b-a1fa-f66522aa9612"
  }]

#Name of the external keypair that will be used to ssh to the bastion
keypair_name = "datacentric_k8s_key" 

#Value of the private part of the ssh keypair that the bastion will use to ssh on instances
#internal_private_key = ""

#Value of the public part of the ssh keypair that the bastion will use to ssh on instances
#internal_public_key = ""

#Name of the internal network the bastion will sit in front of
#internal_network_name = "datacentric_int" 

#ssh connection user name
#ssh_user = "rocky"
