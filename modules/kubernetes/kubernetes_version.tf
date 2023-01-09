#______________________________________________
#
# Kubernetes Version Policy Module
#______________________________________________

#Importing the Kubernetes Version available
data "intersight_kubernetes_version" "version" {
  for_each           = local.kubernetes_version
  kubernetes_version = each.value.version
}

resource "intersight_kubernetes_version_policy" "kubernetes_version" {
  depends_on = [
    data.intersight_kubernetes_version.version
  ]
  for_each    = local.kubernetes_version
  description = each.value.description != "" ? each.value.description : "${each.key} Version Policy."
  name        = each.key
  nr_version {
    moid        = data.intersight_kubernetes_version.version[each.key].results.0.moid
    object_type = "kubernetes.Version"
  }
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
