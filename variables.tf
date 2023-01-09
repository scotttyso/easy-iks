#______________________________________________
#
# Intersight Provider Settings
#______________________________________________

variable "apikey" {
  description = "Intersight API Key."
  #sensitive   = true
  type = string
}

variable "endpoint" {
  default     = "intersight.com"
  description = "Intersight Endpoint Hostname."
  type        = string
}

variable "moids" {
  default     = false
  description = "Flag to Determine if Policies Should be associated using data object or resource."
  type        = bool
}

variable "operating_system" {
  default     = "Linux"
  description = <<-EOF
    Type of Operating System.
    * Linux
    * Windows
  EOF
  type        = string
}

variable "organization" {
  default     = "default"
  description = "Name of the default intersight Organization."
  type        = string
}

variable "name_prefix" {
  default     = ""
  description = "Prefix to Add to Pools, Policies, and Profiles."
  type        = string
}

variable "secretkey" {
  default     = ""
  description = "Intersight Secret Key."
  #sensitive   = true
  type = string
}

variable "secretkeyfile" {
  default     = "blah.txt"
  description = "Intersight Secret Key File Location."
  #sensitive   = true
  type = string
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

variable "kubectl_manifests" {
  default = {}
  type = map(object(
    {
      yaml_body = string
    }
  ))
}
