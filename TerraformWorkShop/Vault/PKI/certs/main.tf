resource "vault_mount" "kvv2" {
  path        = var.vault_kvv2.secret_engine.path
  type        = "kv-v2"
  description = var.vault_kvv2.secret_engine.description
}

resource "vault_pki_secret_backend_cert" "cert" {
  for_each = {
    for cert in var.vault_certs : cert.common_name => cert
  }
  backend     = each.value.secret_engine.backend
  name        = each.value.secret_engine.role_name
  common_name = each.value.common_name
  ttl         = (each.value.ttl_years * 365 * 24 * 60 * 60)
}

data "vault_pki_secret_backend_issuers" "issuers" {
  backend = "pki/root"
}

data "vault_pki_secret_backend_issuer" "issuer" {
  backend    = "pki/root"
  issuer_ref = element(keys(data.vault_pki_secret_backend_issuers.issuers.key_info), 0)
}

resource "vault_kv_secret_v2" "cert" {
  for_each = {
    for cert in var.vault_certs : cert.common_name => cert
  }
  mount = var.vault_kvv2.secret_engine.path
  name  = each.value.common_name
  data_json = jsonencode({
    ca            = data.vault_pki_secret_backend_issuer.issuer.certificate
    cert          = "${vault_pki_secret_backend_cert.cert[each.key].certificate}\n${vault_pki_secret_backend_cert.cert[each.key].ca_chain}"
    private_key   = vault_pki_secret_backend_cert.cert[each.key].private_key
    serial_number = vault_pki_secret_backend_cert.cert[each.key].serial_number
  })
}
