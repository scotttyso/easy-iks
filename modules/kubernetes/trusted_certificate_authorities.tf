#__________________________________________________________________________
#
# Intersight Kubernetes Trusted Certificate Authorities Policy
# GUI Location: Policies > Create Policy > Trusted Certificate Authorities
#__________________________________________________________________________

resource "intersight_kubernetes_trusted_registries_policy" "trusted_certificate_authorities" {
  for_each            = local.trusted_certificate_authorities
  description         = each.value.description != "" ? each.value.description : "${each.key} Trusted Registry Policy."
  name                = each.key
  root_ca_registries  = each.value.root_ca_registries != [] ? each.value.root_ca_registries : []
  unsigned_registries = each.value.unsigned_registries != [] ? each.value.unsigned_registries : []
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
