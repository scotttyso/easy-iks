locals {
  applications      = lookup(var.model, "applications", {})
  defaults          = lookup(var.model, "defaults", {})
  helm_charts       = { for v in lookup(local.applications, "helm_charts", {}) : v.name => v }
  kubectl_manifests = var.kubectl_manifests
  kubeconfig        = yamldecode(var.kubeconfig)
}

#_____________________________________________________________________
#
# Deploy Applications using the Helm Provider
#_____________________________________________________________________

resource "helm_release" "helm_chart" {
  for_each  = { for v in var.applications.helm_charts : v => v }
  chart     = local.helm_charts[each.value].chart
  name      = local.helm_charts[each.value].name
  namespace = local.helm_charts[each.value].namespace
  dynamic "set" {
    for_each = local.helm_charts[each.value].set
    content {
      name     = set.value.name
      value    = set.value.value == "cluster_name" ? "${var.cluster_name}_sample" : set.value.value
    }
  }
}

resource "kubectl_manifest" "manifest" {
  for_each  = { for v in var.applications.kubectl_manifests : v => v }
  yaml_body = local.kubectl_manifests[each.value].yaml_body
}
