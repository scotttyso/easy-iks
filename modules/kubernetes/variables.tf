#__________________________________________________________________
#
# Model Data and policy from pools
#__________________________________________________________________

variable "model" {
  description = "Model data."
  type        = any
}

variable "organization" {
  default     = "default"
  description = "Name of the default intersight Organization."
  type        = string
}

variable "pools" {
  description = "Pool Moids."
  type        = any
}

variable "tags" {
  default     = []
  description = "List of Key/Value Pairs to Assign as Attributes to the Policy."
  type        = list(map(string))
}

#______________________________________________
#
# Container Runtime Policy Variables
#______________________________________________

variable "docker_http_proxy_password" {
  default     = ""
  description = "Password for the Docker HTTP Proxy Server, If required."
  sensitive   = true
  type        = string
}

variable "docker_https_proxy_password" {
  default     = ""
  description = "Password for the Docker HTTPS Proxy Server, If required."
  sensitive   = true
  type        = string
}

#_______________________________________________
#
# Virtual Machine Infra Config Policy Variables
#_______________________________________________

variable "target_password" {
  description = "Target Password.  Note: this is the password of the Credentials used to register the Virtualization Target."
  sensitive   = true
  type        = string
}


#_______________________________________________
#
# Kubernetes Cluster Profile - SSH Key
#_______________________________________________

variable "ssh_public_key" {
  default     = ""
  description = "Intersight Kubernetes Service Cluster SSH Public Key."
  sensitive   = true
  type        = string
}

