#__________________________________________________________________
#
# Intersight Kubernetes Add-ons Policy
# GUI Location: Policies > Create Policy > Add-ons
#__________________________________________________________________

data "intersight_kubernetes_addon_definition" "addons" {
  for_each              = local.addons
  name                  = each.value.chart_name != "" ? each.value.chart_name : each.key
  additional_properties = each.value.chart_version != "" ? jsonencode({ "Version" = "${each.value.chart_version}" }) : ""
}

resource "intersight_kubernetes_addon_policy" "addons" {
  depends_on = [
    data.intersight_kubernetes_addon_definition.addons
  ]
  for_each    = local.addons
  description = each.value.description != "" ? each.value.description : "Kubernetes Add-ons Policy for ${each.key}."
  name        = each.key
  # overrides   = each.value.overrides
  addon_configuration {
    install_strategy  = each.value.install_strategy
    release_name      = each.value.release_name != "" ? each.value.release_name : each.key
    override_sets     = each.value.override_sets
    overrides         = each.value.overrides
    release_namespace = each.value.release_namespace
    upgrade_strategy  = each.value.upgrade_strategy
  }
  addon_definition {
    moid = data.intersight_kubernetes_addon_definition.addons[each.key].results.0.moid
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
