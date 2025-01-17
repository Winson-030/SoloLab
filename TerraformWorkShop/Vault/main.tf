module "ldap_mgmt" {
  source = "./modules/ldap-mgmt"

  vault_ldap_auth = {
    sololab = {
      path         = "ldap"
      url          = "ldaps://ipa.infra.sololab:636"
      insecure_tls = var.ldap_insecure_tls
      certificate  = var.ldap_certificate
      binddn       = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
      bindpass     = var.ldap_bindpass
      userdn       = "cn=users,cn=accounts,dc=infra,dc=sololab"
      userattr     = "mail"
      groupfilter  = "(&(objectClass=posixgroup)(cn=svc-vault-*)(member:={{.UserDN}}))"
      groupdn      = "cn=groups,cn=accounts,dc=infra,dc=sololab"
      groupattr    = "cn"

    }
  }

  # vault policies
  vault_policies = {
    vault-root = {
      policy_content = <<-EOT
        path "secret/*" 
        {
          capabilities = [ "create", "read", "update", "delete", "list", "patch" ]
        }
        # Manage identity
        path "identity/*"
        {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
        path "sys/health"
        {
          capabilities = ["read", "sudo"]
        }
        # Create and manage ACL policies broadly across Vault
        # List existing policies
        path "sys/policies/acl"
        {
          capabilities = ["list"]
        }
        # Create and manage ACL policies
        path "sys/policies/acl/*"
        {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
        # Enable and manage authentication methods broadly across Vault
        # Manage auth methods broadly across Vault
        path "auth/*"
        {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
        # Create, update, and delete auth methods
        path "sys/auth/*"
        {
          capabilities = ["create", "update", "delete", "sudo"]
        }
        # List auth methods
        path "sys/auth"
        {
          capabilities = ["read"]
        }
        # Enable and manage the key/value secrets engine at `secret/` path
        # List, create, update, and delete key/value secrets
        path "secret/*"
        {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
        # Manage secrets engines
        path "sys/mounts/*"
        {
          capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        }
        # List existing secrets engines.
        path "sys/mounts"
        {
          capabilities = ["read"]
        }
      EOT
    }
  }

  # groups
  vault_groups = {
    vault-root = {
      type     = "external"
      policies = ["vault-root"]
      alias = [
        {
          name     = "svc-vault-root"
          ldap_key = "sololab"
        }
      ]
    }
  }
}
