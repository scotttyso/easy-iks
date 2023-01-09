#__________________________________________________________________
#
# Intersight Kubernetes Container Runtime Policy
# GUI Location: Policies > Create Policy > Container Runtime
#__________________________________________________________________

resource "intersight_kubernetes_container_runtime_policy" "container_runtime" {
  for_each                   = local.container_runtime
  description                = each.value.description != "" ? each.value.description : "${each.key} Runtime Policy."
  name                       = each.key
  docker_bridge_network_cidr = each.value.docker_daemon_bridge_cidr
  docker_no_proxy            = each.value.docker_no_proxy
  organization {
    moid        = local.orgs[lookup(each.value, "organization", var.organization)]
    object_type = "organization.Organization"
  }
  dynamic "docker_http_proxy" {
    for_each = { for k, v in each.value.docker_http_proxy : k => v if length(regexall("[a-zA-Z0-9]", v.hostname)) > 0 }
    content {
      hostname = docker_http_proxy.value.hostname
      password = length(regexall("[a-zA-Z]", docker_http_proxy.value.username)) > 0 ? var.docker_http_proxy_password : ""
      port     = docker_http_proxy.value.port != null ? docker_http_proxy.value.port : 8080
      protocol = docker_http_proxy.value.protocol != null ? docker_http_proxy.value.protocol : "http"
      username = docker_http_proxy.value.username
    }
  }
  dynamic "docker_https_proxy" {
    for_each = { for k, v in each.value.docker_https_proxy : k => v if length(regexall("[a-zA-Z0-9]", v.hostname)) > 0 }
    content {
      hostname = docker_https_proxy.value.hostname
      password = length(regexall("[a-zA-Z]", docker_https_proxy.value.username)) > 0 ? var.docker_https_proxy_password : ""
      port     = docker_https_proxy.value.port != null ? docker_https_proxy.value.port : 8443
      protocol = docker_https_proxy.value.protocol != null ? docker_https_proxy.value.protocol : "https"
      username = docker_https_proxy.value.username
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
