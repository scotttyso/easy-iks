output "helm_charts" {
  description = "Names of the Helm Charts for Each Cluster."
  value = sort(keys(helm_release.helm_chart))
}

output "kubectl_manifests" {
  description = "Names of the Kubectl Manifests for Each Cluster."
  value = sort(keys(kubectl_manifest.manifest))
}

