variable "cluster_name" {
  description = "Name of the Cluster to push Policy to"
  type        = string
}

variable "applications" {
  default = {
    helm_charts = []
    kubectl_manifests = []
  }
  type = object(
    {
      helm_charts       = optional(list(string), [])
      kubectl_manifests = optional(list(string), [])
    }
  )
}

variable "kubectl_manifests" {
  default = {}
  type = map(object(
    {
      yaml_body = string
    }
  ))
}

variable "kubeconfig" {
  type = any
}

variable "model" {
  description = "Model data."
  type        = any
}

