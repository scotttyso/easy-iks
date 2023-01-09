output "applications" {
  value = module.applications
}

output "kubernetes" {
  description = "The Name of Each Policy Created with it's respective Moid."
  value       = module.kubernetes
}

output "pools" {
  description = "The Name of Each Pool Created with it's respective Moid."
  value       = module.pools
}

