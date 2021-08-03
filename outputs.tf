output "dn" {
  value       = aci_rest.infraNodeP.id
  description = "Distinguished name of `infraNodeP` object."
}

output "name" {
  value       = aci_rest.infraNodeP.content.name
  description = "Leaf switch profile name."
}
