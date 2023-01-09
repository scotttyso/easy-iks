#_________________________________________________________________________________________
#
# Data Model Merge Process - Merge YAML Files into HCL Format
#_________________________________________________________________________________________
locals {
  model = yamldecode(data.utils_yaml_merge.model.output)
}

data "utils_yaml_merge" "model" {
  input = concat([
    for file in fileset(path.module, "applications/*.yaml") : file(file)], [
    for file in fileset(path.module, "defaults/*.yaml") : file(file)], [
    for file in fileset(path.module, "kubernetes/*.yaml") : file(file)], [
    for file in fileset(path.module, "pools/*.yaml") : file(file)]
  )
  merge_list_items = false
}
#_________________________________________________________________________________________
#
# Intersight:Pools
# GUI Location: Infrastructure Service > Configure > Pools
#_________________________________________________________________________________________
module "pools" {
  #source = "../terraform-intersight-pools"
  source       = "terraform-cisco-modules/pools/intersight"
  version      = "= 1.0.12"
  model        = local.model
  organization = var.organization
  tags         = var.tags
}

module "kubernetes" {
  source = "/home/tyscott@rich.ciscolabs.com/github/terraform-intersight-easy-iks/modules/kubernetes"
  #source       = "terraform-cisco-modules/kubernetes/intersight"
  #version      = "1.0.12"
  model        = local.model
  organization = var.organization
  pools        = module.pools
  tags         = var.tags
  # Sensitive Variables - Container Runtime
  docker_http_proxy_password  = var.docker_http_proxy_password
  docker_https_proxy_password = var.docker_https_proxy_password
  # Sensitive Variables - VM Infra Configuration
  target_password = var.target_password
}

resource "intersight_kubernetes_cluster_profile" "kubernetes_cluster_profiles" {
  depends_on = [
    module.kubernetes
  ]
  for_each = module.kubernetes.kubernetes_cluster_profiles
  action   = each.value.action
  name     = each.value.name
  lifecycle {
    ignore_changes = [
      cert_config,
      cluster_ip_pools,
      container_runtime_config,
      management_config,
      net_config,
      shared_scope,
      status,
      sys_config,
      tags,
      trusted_registries
    ]
  }
  organization {
    moid = module.pools.orgs[each.value.organization]
  }
  wait_for_completion = module.kubernetes.kubernetes_cluster_profiles[
    element(keys(module.kubernetes.kubernetes_cluster_profiles), length(keys(module.kubernetes.kubernetes_cluster_profiles)
  ) - 1)].name == each.value.name ? true : false
}

resource "intersight_kubernetes_node_group_profile" "kubernetes_node_pools" {
  depends_on = [
    intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles
  ]
  for_each = module.kubernetes.kubernetes_node_pools
  action   = each.value.action
  name     = each.value.name
  cluster_profile {
    moid        = intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles[each.value.kubernetes_cluster_profile].moid
    object_type = "kubernetes.ClusterProfile"
  }
  lifecycle {
    ignore_changes = [
      description,
      desiredsize,
      ip_pools,
      kubernetes_version,
      labels,
      maxsize,
      minsize,
      node_type,
      tags
    ]
  }
}

data "intersight_kubernetes_cluster" "kubeconfigs" {
  depends_on = [
    intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles
  ]
  for_each = module.kubernetes.kubernetes_cluster_profiles
  name     = each.key
}

module "applications" {
  source = "/home/tyscott@rich.ciscolabs.com/github/terraform-intersight-easy-iks/modules/applications"
  #source     = "terraform-cisco-modules/policies/intersight"
  #version    = "1.0.12"
  #for_each   = module.kubernetes.kubernetes_cluster_profiles
  cluster_name      = "asgard_cl1"
  applications      = {
    helm_charts = ["helloiksapp", "iwok8scollector"]
    #kubectl_manifests = ["hippsterstore"]
  }
  kubectl_manifests = var.kubectl_manifests
  kubeconfig        = base64decode(data.intersight_kubernetes_cluster.kubeconfigs["asgard_cl1"].results[0].kube_config)
  model             = local.model
}
