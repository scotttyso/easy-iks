#__________________________________________________________________
#
# Intersight Kubernetes Network CIDR Policy
# GUI Location: Policies > Create Policy > Network CIDR
#__________________________________________________________________

resource "intersight_kubernetes_network_policy" "network_cidr" {
  for_each         = local.network_cidr
  cni_type         = each.value.cni_type
  description      = each.value.description != "" ? each.value.description : "${each.key} Kubernetes Network CIDR Policy."
  name             = each.key
  pod_network_cidr = each.value.pod_network_cidr
  service_cidr     = each.value.service_cidr
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
