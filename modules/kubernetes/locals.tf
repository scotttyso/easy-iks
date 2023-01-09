locals {
  defaults   = lookup(var.model, "defaults", {})
  intersight = lookup(var.model, "intersight", {})
  policies   = lookup(local.intersight, "policies", {})
  profiles   = lookup(local.intersight, "profiles", {})
  k8s        = local.defaults.intersight.profiles.kubernetes_cluster
  laddons    = local.defaults.intersight.policies.addons
  lcidr      = local.defaults.intersight.policies.network_cidr
  lnodeos    = local.defaults.intersight.policies.nodeos_configuration
  lruntime   = local.defaults.intersight.policies.container_runtime
  ltcertauth = local.defaults.intersight.policies.trusted_certificate_authorities
  lversion   = local.defaults.intersight.policies.kubernetes_version
  lvminfra   = local.defaults.intersight.policies.virtual_machine_infra_config
  lvminsta   = local.defaults.intersight.policies.virtual_machine_instance_type
  orgs       = var.pools.orgs
  tags       = var.tags

  # Kubernetes Cluster Profiles Variables
  addons = {
    for v in lookup(local.policies, "addons", {}) : v.name => {
      chart_name       = lookup(v, "chart_name", local.laddons.chart_name)
      chart_version    = lookup(v, "chart_version", local.laddons.chart_version)
      description      = lookup(v, "description", local.laddons.description)
      install_strategy = lookup(v, "install_strategy", local.laddons.install_strategy)
      override_sets    = lookup(v, "override_sets", local.laddons.override_sets)
      overrides = length(lookup(v, "overrides", local.laddons.overrides)) > 0 ? yamlencode(
        {
          "${element(lookup(v, "overrides", local.laddons.overrides), 0)}" : {
            "${element(lookup(v, "overrides", local.laddons.overrides), 1)}" : "${element(lookup(v, "overrides", local.laddons.overrides), 2)}"
          }
        }
      ) : ""
      release_name      = lookup(v, "release_name", local.laddons.release_name)
      release_namespace = lookup(v, "release_namespace", local.laddons.release_namespace)
      tags              = lookup(v, "tags", var.tags)
      upgrade_strategy  = lookup(v, "upgrade_strategy", local.laddons.upgrade_strategy)
    }
  }
  container_runtime = {
    for v in lookup(local.policies, "container_runtime", {}) : v.name => {
      description               = lookup(v, "description", local.lruntime.description)
      docker_daemon_bridge_cidr = lookup(v, "docker_daemon_bridge_cidr", local.lruntime.docker_daemon_bridge_cidr)
      docker_no_proxy           = lookup(v, "docker_no_proxy", local.lruntime.docker_no_proxy)
      docker_http_proxy         = lookup(v, "docker_http_proxy", local.lruntime.docker_http_proxy)
      docker_https_proxy        = lookup(v, "docker_https_proxy", local.lruntime.docker_https_proxy)
      tags                      = lookup(v, "tags", var.tags)
    }
  }
  kubernetes_version = {
    for v in lookup(local.policies, "kubernetes_version", {}) : v.name => {
      description = lookup(v, "description", local.lversion.description)
      tags        = lookup(v, "tags", var.tags)
      version     = lookup(v, "version", local.lversion.version)
    }
  }
  network_cidr = {
    for v in lookup(local.policies, "network_cidr", {}) : v.name => {
      cni_type         = lookup(v, "cni_type", local.lcidr.cni_type)
      description      = lookup(v, "description", local.lcidr.description)
      pod_network_cidr = lookup(v, "pod_network_cidr", local.lcidr.pod_network_cidr)
      service_cidr     = lookup(v, "service_cidr", local.lcidr.service_cidr)
      tags             = lookup(v, "tags", var.tags)
    }
  }
  nodeos_configuration = {
    for v in lookup(local.policies, "nodeos_configuration", {}) : v.name => {
      description = lookup(v, "description", local.lnodeos.description)
      dns_servers = lookup(v, "dns_servers", local.lnodeos.dns_servers)
      dns_suffix  = lookup(v, "dns_suffix", local.lnodeos.dns_suffix)
      ntp_servers = lookup(v, "ntp_servers", local.lnodeos.ntp_servers)
      tags        = lookup(v, "tags", var.tags)
      timezone    = lookup(v, "timezone", local.lnodeos.timezone)
    }
  }
  trusted_certificate_authorities = {
    for v in lookup(local.policies, "trusted_certificate_authorities", {}) : v.name => {
      description         = lookup(v, "description", local.ltcertauth.description)
      root_ca_registries  = lookup(v, "root_ca_registries", local.ltcertauth.root_ca_registries)
      tags                = lookup(v, "tags", var.tags)
      unsigned_registries = lookup(v, "unsigned_registries", local.ltcertauth.unsigned_registries)
    }
  }
  virtual_machine_infra_config = {
    for v in lookup(local.policies, "virtual_machine_infra_config", {}) : v.name => {
      description = lookup(v, "description", local.lvminfra.description)
      tags        = lookup(v, "tags", var.tags)
      target      = lookup(v, "target", local.lvminfra.target)
      virtual_infrastructure = [
        for value in lookup(v, "virtual_infrastructure", local.lvminfra.virtual_infrastructure) : {
          cluster       = lookup(value, "cluster", local.lvminfra.virtual_infrastructure.cluster)
          datastore     = lookup(value, "datastore", local.lvminfra.virtual_infrastructure.datastore)
          disk_mode     = lookup(value, "disk_mode", local.lvminfra.virtual_infrastructure.disk_mode)
          interfaces    = lookup(value, "interfaces", local.lvminfra.virtual_infrastructure.interfaces)
          ip_pool       = lookup(value, "ip_pool", local.lvminfra.virtual_infrastructure.ip_pool)
          mtu           = lookup(value, "mtu", local.lvminfra.virtual_infrastructure.mtu)
          provider_name = lookup(value, "provider_name", local.lvminfra.virtual_infrastructure.provider_name)
          resource_pool = lookup(value, "resource_pool", local.lvminfra.virtual_infrastructure.resource_pool)
          type          = lookup(value, "type", local.lvminfra.virtual_infrastructure.type)
          vrf           = lookup(value, "vrf", local.lvminfra.virtual_infrastructure.vrf)
        }
      ]
    }
  }
  virtual_machine_instance_type = {
    for v in lookup(local.policies, "virtual_machine_instance_type", {}) : v.name => {
      description      = lookup(v, "description", local.lvminsta.description)
      cpu              = lookup(v, "cpu", local.lvminsta.cpu)
      memory           = lookup(v, "memory", local.lvminsta.memory)
      system_disk_size = lookup(v, "system_disk_size", local.lvminsta.system_disk_size)
      tags             = lookup(v, "tags", var.tags)
    }
  }


  #__________________________________________________________
  #
  # Kubernetes Cluster Profiles Variables
  #__________________________________________________________

  kubernetes_cluster_profiles = {
    for v in lookup(local.profiles, "kubernetes_cluster", {}) : v.name => {
      action                    = lookup(v, "action", local.k8s.action)
      addons_policies           = lookup(v, "addons_policies", local.k8s.addons_policies)
      applications              = lookup(v, "applications", local.k8s.applications)
      certificate_configuration = lookup(v, "certificate_configuration", local.k8s.certificate_configuration)
      cluster_configuration = [
        for value in lookup(v, "cluster_configuration", []) : {
          kubernetes_api_vip  = lookup(value, "kubernetes_api_vip", local.k8s.cluster_configuration.kubernetes_api_vip)
          load_balancer_count = lookup(value, "load_balancer_count", local.k8s.cluster_configuration.load_balancer_count)
        }
      ]
      container_runtime_policy      = lookup(v, "container_runtime_policy", local.k8s.container_runtime_policy)
      description                   = lookup(v, "description", local.k8s.description)
      ip_pool                       = v.ip_pool
      name                          = v.name
      network_cidr_policy           = v.network_cidr_policy
      node_pools                    = lookup(v, "node_pools", [])
      nodeos_configuration_policy   = v.nodeos_configuration_policy
      organization                  = lookup(v, "organization", var.organization)
      tags                          = lookup(v, "tags", var.tags)
      trusted_certificate_authority = lookup(v, "trusted_certificate_authority", local.k8s.trusted_certificate_authority)
      wait_for_completion           = lookup(v, "wait_for_completion", local.k8s.wait_for_completion)
    }
  }

  kubernetes_node_pools = { for i in flatten([
    for key, value in local.kubernetes_cluster_profiles : [
      for v in value.node_pools : {
        action                     = value.action
        desired_size               = lookup(v, "desired_size", local.k8s.node_pools.desired_size)
        description                = lookup(v, "description", local.k8s.node_pools.description)
        min_size                   = lookup(v, "min_size", local.k8s.node_pools.min_size)
        max_size                   = lookup(v, "max_size", local.k8s.node_pools.max_size)
        name                       = v.name
        node_type                  = lookup(v, "node_type", local.k8s.node_pools.node_type)
        ip_pool                    = length(compact([lookup(v, "ip_pool", "")])) > 0 ? v.ip_pool : value.ip_pool
        kubernetes_cluster_profile = key
        kubernetes_labels          = lookup(v, "kubernetes_labels", local.k8s.node_pools.kubernetes_labels)
        kubernetes_version_policy  = v.kubernetes_version_policy
        organization               = value.organization
        tags                       = value.tags
        vm_infra_config_policy     = v.vm_infra_config_policy
        vm_instance_type_policy    = v.vm_instance_type_policy
      }
    ]
  ]) : "${i.kubernetes_cluster_profile}:${i.name}" => i }

}
