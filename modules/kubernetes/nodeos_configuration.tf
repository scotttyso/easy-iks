#__________________________________________________________________
#
# Intersight Kubernetes Node OS Configuration Policy
# GUI Location: Policies > Create Policy > Node OS Configuration
#__________________________________________________________________

resource "intersight_kubernetes_sys_config_policy" "nodeos_config" {
  for_each        = local.nodeos_configuration
  description     = each.value.description != "" ? each.value.description : "${each.key} Kubernetes Network CIDR Policy."
  dns_domain_name = each.value.dns_suffix
  dns_servers     = each.value.dns_servers
  name            = each.key
  ntp_servers     = each.value.ntp_servers != [] ? each.value.ntp_servers : each.value.dns_servers
  timezone        = each.value.timezone
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
