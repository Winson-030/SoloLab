data "vault_kv_secret_v2" "ca_cert" {
  mount = "kvv2/certs"
  name  = "root"
}

resource "vault_consul_secret_backend" "backend" {
  path        = "consul"
  description = "Manages the Consul backend"
  scheme      = var.prov_consul.scheme
  address     = var.prov_consul.address
  token       = var.prov_consul.token
  ca_cert     = data.vault_kv_secret_v2.ca_cert.data["ca"]
}

resource "vault_consul_secret_backend_role" "admin" {
  name    = "global-management"
  backend = vault_consul_secret_backend.backend.path
  consul_policies = [
    "global-management"
  ]
  ttl = 3600
}

module "consul_jwt_auth_policy_bindings" {
  source = "../../../modules/vault-policy_binding"
  policy_bindings = [{
    policy_name     = "Consul-ACL_Token"
    policy_content  = <<-EOT
      path "consul/creds/global-management" {
        capabilities = ["read"]
      }
      EOT
    policy_group    = "Policy-Consul-Admin"
    external_groups = ["App-Consul-Admin"]
  }]

}
