prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer_host = "vault.day0.sololab"
  # https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
  scopes = [
    {
      name     = "username"
      template = <<-EOT
      {
        "username": {{identity.entity.name}}
      }
      EOT
    },
    {
      name     = "groups"
      template = <<-EOT
      {
        "groups": {{identity.entity.groups.names}}
      }
      EOT
    },
    {
      name     = "minio_scope"
      template = <<-EOT
      {
        "policy": {{identity.entity.groups.names}}
      }
      EOT
    },
  ]
}

oidc_client = [
  # {
  #   name         = "example-app"
  #   allow_groups = ["app-minio-admin"]
  #   redirect_uris = [
  #     "http://example-app.day0.sololab/callback",
  #   ]
  # },
  # {
  #   name         = "minio"
  #   allow_groups = ["app-minio-user"]
  #   redirect_uris = [
  #     "https://minio-console.day0.sololab/oauth_callback",
  #   ]
  # },
  {
    name         = "nomad"
    allow_groups = ["app-nomad-user"]
    redirect_uris = [
      "https://nomad.day0.sololab/oidc/callback",
      "https://nomad.day0.sololab/ui/settings/tokens",
    ]
  },
]
