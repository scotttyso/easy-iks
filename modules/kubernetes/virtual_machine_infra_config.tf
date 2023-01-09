#_______________________________________________________________________
#
# Intersight Kubernetes Virtual Machine Infra Config Policy
# GUI Location: Policies > Create Policy > Virtual Machine Infra Config
#_______________________________________________________________________

data "intersight_asset_target" "target" {
  for_each = local.virtual_machine_infra_config
  name     = each.value.target
}

resource "intersight_kubernetes_virtual_machine_infra_config_policy" "virtual_machine_infra_config" {
  depends_on = [
    data.intersight_asset_target.target
  ]
  for_each    = local.virtual_machine_infra_config
  description = each.value.description != "" ? each.value.description : "${each.key} Virtual Machine Infra Config Policy."
  name        = each.key
  organization {
    moid        = local.orgs[lookup(each.value, "organization", var.organization)]
    object_type = "organization.Organization"
  }
  target {
    object_type = "asset.DeviceRegistration"
    moid        = data.intersight_asset_target.target[each.key].results.0.registered_device[0].moid
  }
  dynamic "vm_config" {
    for_each = { for k, v in each.value.virtual_infrastructure : k => v if v.type == "vmware" }
    content {
      additional_properties = jsonencode({
        Datastore    = vm_config.value.datastore
        Cluster      = vm_config.value.cluster
        ResourcePool = vm_config.value.resource_pool
      })
      interfaces  = vm_config.value.interfaces
      object_type = "kubernetes.EsxiVirtualMachineInfraConfig"

    }
  }
  dynamic "vm_config" {
    for_each = { for k, v in each.value.virtual_infrastructure : k => v if v.type == "iwe" }
    content {
      additional_properties = jsonencode({
        DiskMode   = vm_config.value.disk_mode
        Passphrase = var.target_password
      })
      interfaces = vm_config.value.interfaces
      network_interfaces {
        mtu  = vm_config.value.mtu
        name = vm_config.value.name
        pools {
          moid = length(compact([vm_config.value.ip_pool])) > 0 ? var.pools.ip[out_of_band_ip_pool.value] : ""
        }
        provider_name = vm_config.value.provider_name
        vrf {
          moid        = vm_config.value.vrf != "" ? vm_config.value.vrf : ""
          object_type = "vrf.Vrf"
        }
      }
      object_type = "kubernetes.HyperFlexApVirtualMachineInfraConfig"

    }
  }
  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
