#__________________________________________________________
#
# Kubernetes Policy Outputs
#__________________________________________________________

output "addons" {
  description = "moid of the Kubernetes Addon Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_addon_policy.addons)
    ) : v => {
    moid = intersight_kubernetes_addon_policy.addons[v].moid
    name = intersight_kubernetes_addon_policy.addons[v].name
    }
  }
}

output "container_runtime" {
  description = "moid of the Kubernetes Runtime Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_container_runtime_policy.container_runtime)
  ) : v => intersight_kubernetes_container_runtime_policy.container_runtime[v].moid }
}

output "kubernetes_version" {
  description = "moid of the Kubernetes Version Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_version_policy.kubernetes_version)
  ) : v => intersight_kubernetes_version_policy.kubernetes_version[v].moid }
}

output "network_cidr" {
  description = "moid of the Kubernetes Network CIDR Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_network_policy.network_cidr)
  ) : v => intersight_kubernetes_network_policy.network_cidr[v].moid }
}

output "nodeos_configuration" {
  description = "moid of the Kubernetes Node OS Config Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_sys_config_policy.nodeos_config)
  ) : v => intersight_kubernetes_sys_config_policy.nodeos_config[v].moid }
}

output "trusted_certificate_authorities" {
  description = "moid of the Kubernetes Trusted Certificate Authorities Policy."
  value = { for v in sort(keys(
    intersight_kubernetes_trusted_registries_policy.trusted_certificate_authorities)
  ) : v => intersight_kubernetes_trusted_registries_policy.trusted_certificate_authorities[v].moid }
}

output "virtual_machine_infra_config" {
  description = "moid of the Kubernetes Virtual Machine Infrastructure Configuration Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_virtual_machine_infra_config_policy.virtual_machine_infra_config)
  ) : v => intersight_kubernetes_virtual_machine_infra_config_policy.virtual_machine_infra_config[v].moid }
}

output "virtual_machine_instance_type" {
  description = "moid of the Virtual Machine Instance Type Policies."
  value = { for v in sort(keys(
    intersight_kubernetes_virtual_machine_instance_type.virtual_machine_instance_type)
  ) : v => intersight_kubernetes_virtual_machine_instance_type.virtual_machine_instance_type[v].moid }
}

output "kubernetes_cluster_profiles" {
  value = local.kubernetes_cluster_profiles
}

output "kubernetes_node_pools" {
  value = local.kubernetes_node_pools
}