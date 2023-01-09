#__________________________________________________________________________________________
#
# Kubernetes Cluster Profile
# GUI Location: Profiles > Kubernetes Cluster Profiles > Create Kubernetes Cluster Profile
#__________________________________________________________________________________________

resource "intersight_kubernetes_cluster_profile" "kubernetes_cluster_profiles" {
  depends_on = [
    intersight_kubernetes_addon_policy.addons,
    intersight_kubernetes_container_runtime_policy.container_runtime,
    intersight_kubernetes_version_policy.kubernetes_version,
    intersight_kubernetes_network_policy.network_cidr,
    intersight_kubernetes_sys_config_policy.nodeos_config,
    intersight_kubernetes_trusted_registries_policy.trusted_certificate_authorities,
    intersight_kubernetes_virtual_machine_infra_config_policy.virtual_machine_infra_config,
    intersight_kubernetes_virtual_machine_instance_type.virtual_machine_instance_type
  ]
  for_each    = local.kubernetes_cluster_profiles
  description = each.value.description != "" ? each.value.description : "${each.key} IKS Cluster."
  name        = each.key
  cluster_ip_pools {
    moid = var.pools.ip[each.value.ip_pool]
  }
  dynamic "management_config" {
    for_each = each.value.cluster_configuration
    content {
      load_balancer_count = management_config.value.load_balancer_count
      master_vip          = management_config.value.kubernetes_api_vip
      ssh_keys            = [var.ssh_public_key]
    }
  }
  lifecycle {
    ignore_changes = [
      shared_scope,
      status
    ]
  }
  net_config {
    moid = intersight_kubernetes_network_policy.network_cidr[each.value.network_cidr_policy].moid
  }
  organization {
    moid        = local.orgs[lookup(each.value, "organization", var.organization)]
    object_type = "organization.Organization"
  }
  sys_config {
    moid = intersight_kubernetes_sys_config_policy.nodeos_config[each.value.nodeos_configuration_policy].moid
  }
  dynamic "cert_config" {
    for_each = each.value.certificate_configuration == true ? each.value.cluster_configuration : []
    content {
      ca_cert             = var.api_server_certificate
      ca_key              = var.api_server_key
      etcd_cert           = var.etcd_certificate
      etcd_encryption_key = var.etcd_encryption_key
      etcd_key            = var.etcd_key
      front_proxy_cert    = var.front_proxy_certificate
      front_proxy_key     = var.front_proxy_key
      sa_private_key      = var.service_account_private_key
      sa_public_key       = var.service_account_public_key
    }
  }
  dynamic "container_runtime_config" {
    for_each = length(compact([each.value.container_runtime_policy])) > 0 ? toset(
      [each.value.container_runtime_policy]
    ) : []
    content {
      moid = intersight_kubernetes_container_runtime_policy.container_runtime[container_runtime_config.value].moid
    }
  }
  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
  dynamic "trusted_registries" {
    for_each = length(compact([each.value.trusted_certificate_authority])) > 0 ? toset(
      [each.value.trusted_certificate_authority]
    ) : []
    content {
      moid = intersight_kubernetes_trusted_registries_policy.trusted_certificate_authorities[trusted_registries.value].moid
    }
  }
}

#__________________________________________________________________________________________
#
# Kubernetes Cluster - Add-ons
# GUI Location: Profiles > Kubernetes Cluster Profiles > Create Kubernetes Cluster Profile
#__________________________________________________________________________________________

#_____________________________________________________
#
# Attach the Add-Ons Policy to the Kubernetes Cluster
#_____________________________________________________

resource "intersight_kubernetes_cluster_addon_profile" "cluster_addon" {
  depends_on = [
    intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles
  ]
  for_each = { for k, v in local.kubernetes_cluster_profiles : k => v if length(v.addons_policies) > 0 }
  name     = each.key
  associated_cluster {
    moid = intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles[each.key].associated_cluster[0].moid
  }
  organization {
    moid        = local.orgs[lookup(each.value, "organization", var.organization)]
    object_type = "organization.Organization"
  }
  dynamic "addons" {
    for_each = toset(each.value.addons_policies)
    content {
      addon_policy {
        moid = intersight_kubernetes_addon_policy.addons["${addons.value}"].moid
      }
      name = intersight_kubernetes_addon_policy.addons["${addons.value}"].name
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


#______________________________________________
#
# Create the Control Plane Profile
#______________________________________________

#__________________________________________________________________________________________
#
# Intersight Kubernetes - Node Group Profiles
# GUI Location: Profiles > Kubernetes Cluster Profiles > Create Kubernetes Cluster Profile
#__________________________________________________________________________________________

resource "intersight_kubernetes_node_group_profile" "kubernetes_node_pools" {
  depends_on = [
    intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles
  ]
  for_each    = local.kubernetes_node_pools
  description = each.value.description
  desiredsize = each.value.desired_size
  maxsize     = each.value.max_size
  minsize     = each.value.min_size
  name        = each.value.name
  node_type   = each.value.node_type
  ip_pools {
    moid        = var.pools.ip[each.value.ip_pool]
    object_type = "ippool.Pool"
  }
  kubernetes_version {
    moid        = intersight_kubernetes_version_policy.kubernetes_version[each.value.kubernetes_version_policy].moid
    object_type = "kubernetes.VersionPolicy"
  }
  cluster_profile {
    moid        = intersight_kubernetes_cluster_profile.kubernetes_cluster_profiles[each.value.kubernetes_cluster_profile].moid
    object_type = "kubernetes.ClusterProfile"
  }
  dynamic "labels" {
    for_each = each.value.kubernetes_labels
    content {
      key   = labels.value.key
      value = labels.value.value
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


#____________________________________________________________
#
# Intersight Kubernetes Virtual Machine Infrastructure Provider
# GUI Location: Policies > Create Policy
#____________________________________________________________

resource "intersight_kubernetes_virtual_machine_infrastructure_provider" "k8s_vm_infra_provider" {
  depends_on = [
    intersight_kubernetes_node_group_profile.kubernetes_node_pools
  ]
  for_each    = local.kubernetes_node_pools
  description = each.value.description != "" ? each.value.description : "${each.value.name} Kubernetes Virtual machine Infrastructure Provider"
  name        = each.value.name
  infra_config_policy {
    moid = intersight_kubernetes_virtual_machine_infra_config_policy.virtual_machine_infra_config[
      each.value.vm_infra_config_policy
    ].moid
  }
  instance_type {
    moid = intersight_kubernetes_virtual_machine_instance_type.virtual_machine_instance_type[
      each.value.vm_instance_type_policy
    ].moid
  }
  node_group {
    moid = intersight_kubernetes_node_group_profile.kubernetes_node_pools[each.key].moid
  }
  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
