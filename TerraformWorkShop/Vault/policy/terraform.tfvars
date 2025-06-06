prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

policy_bindings = [
  {
    policy_name     = "admin"
    policy_content  = <<-EOT
      path "*" {
        capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
      }
      EOT
    policy_group    = "Policy-Vault-Admin"
    external_groups = ["app-vault-admin"]
  },
  {
    policy_name     = "user"
    policy_content  = <<-EOT
      path "identity/group/*" {
        capabilities = ["read", "list"]
      }
      EOT
    policy_group    = "Policy-Vault-User"
    external_groups = ["app-vault-user"]
  },
]
