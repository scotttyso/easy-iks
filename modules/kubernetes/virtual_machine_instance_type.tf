#________________________________________________________________________
#
# Intersight Kubernetes Virtual Machine Instance Type Policy
# GUI Location: Policies > Create Policy > Virtual Machine Instance Type
#________________________________________________________________________

resource "intersight_kubernetes_virtual_machine_instance_type" "virtual_machine_instance_type" {
  for_each    = local.virtual_machine_instance_type
  cpu         = each.value.cpu
  description = each.value.description != "" ? each.value.description : "${each.key} Virtual Machine Instance Policy."
  disk_size   = each.value.system_disk_size
  memory      = each.value.memory
  name        = each.key
  organization {
    moid        = local.orgs[lookup(each.value, "organization", var.organization)]
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
