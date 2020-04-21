
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "iso_datastore" {
  name          = var.vsphere_iso_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_resource_pool" "pool" {
  name                    = var.vsphere_resourcepool
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}


// data "vsphere_resource_pool" "pool" {
//  name          = var.vsphere_cluster}/Resources/${var.vsphere_resourcepool
//  datacenter_id = data.vsphere_datacenter.dc.id
// }

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

//data "vsphere_virtual_machine" "template" {
//  name          = var.vsphere_template
//  datacenter_id = data.vsphere_datacenter.dc.id
//}

resource "vsphere_virtual_machine" "bootstrap" {

  wait_for_guest_net_timeout = -1 
  enable_disk_uuid = true

  count            = "1"
  name             = "tf-boot-${count.index + 1}" 
  resource_pool_id = vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 16384
  guest_id = "other3xLinux64Guest"
  //guest_id = data.vsphere_virtual_machine.template.guest_id
  //scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id = data.vsphere_network.network.id
    //adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = "disk0"
    size  = 60
  }

  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "ISO/rhcos-4.3.0-x86_64-installer.iso"
  }

//  disk {
//    label            = "disk0"
//    size             = data.vsphere_virtual_machine.template.disks.0.size ## 60GB min
//    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
//    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
//  }

//  // No need to use OVA without DHCP
//  clone {
//    template_uuid = data.vsphere_virtual_machine.template.id
//
//  }

}

resource "vsphere_virtual_machine" "controlplane" {

  wait_for_guest_net_timeout = -1
  enable_disk_uuid = true

  count            = "3"
  name             = "tf-control-${count.index + 1}" 
  resource_pool_id = vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 16384
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 60
  }

  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "ISO/rhcos-4.3.0-x86_64-installer.iso"
  }


}

resource "vsphere_virtual_machine" "compute" {

  wait_for_guest_net_timeout = -1
  enable_disk_uuid = true

  count            = "0"
  name             = "tf-compute-${count.index + 1}" 
  resource_pool_id = vsphere_resource_pool.pool.id 
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8192
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 60
  }

  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "ISO/rhcos-4.3.0-x86_64-installer.iso"
  }


}

