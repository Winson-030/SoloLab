prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_ldap = {
  host          = "opendj.day1.sololab"
  port          = "636"
  tls           = true
  tls_insecure  = true
  bind_user     = "uid=admin,ou=People,dc=root,dc=sololab"
  bind_password = "P@ssw0rd"
}

vault_ldap_auth_backend = {
  path         = "ldap"
  url          = "ldaps://opendj.day1.sololab"
  insecure_tls = false
  #   certificate  = data.terraform_remote_state.root_ca.outputs.root_cert_pem

  # opendj
  binddn      = "uid=readonly,ou=Services,dc=root,dc=sololab"
  bindpass    = "P@ssw0rd"
  userdn      = "ou=People,dc=root,dc=sololab"
  userattr    = "mail"
  userfilter  = "(&({{.UserAttr}}={{.Username}})(objectClass=person)(isMemberOf=cn=sso_allow,ou=Groups,dc=root,dc=sololab))"
  groupdn     = "ou=Groups,dc=root,dc=sololab"
  groupattr   = "cn"
  groupfilter = "(&(objectClass=groupOfUniqueNames)(cn=App-*)(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})))"

  ## freeipa
  #   binddn       = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
  #   bindpass     = var.ldap_bindpass
  #   userdn       = "cn=users,cn=accounts,dc=infra,dc=sololab"
  #   userattr     = "mail"
  #   groupfilter  = "(&(objectClass=posixgroup)(cn=svc-vault-*)(member:={{.UserDN}}))"
  #   groupdn      = "cn=groups,cn=accounts,dc=infra,dc=sololab"
  #   groupattr    = "cn"

  ## lldap
  # binddn   = "cn=readonly,ou=people,dc=root,dc=sololab"
  # bindpass = "readonly"
  # userdn   = "ou=people,dc=root,dc=sololab"
  # userattr = "uid"
  ## do not use upper case group name
  # userfilter  = "(&({{.UserAttr}}={{.Username}})(objectClass=person)(memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab))"
  # groupdn     = "ou=groups,dc=root,dc=sololab"
  # groupattr   = "cn"
  # groupfilter = "(&(objectClass=groupOfUniqueNames)(cn=app-*)(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})))"

  token_max_ttl = 3600
}

ldap_vault_entities = {
  users = {
    ou = "ou=People,dc=root,dc=sololab"
    # opendj
    filter = "(&(objectClass=person)(isMemberOf=cn=sso_allow,ou=Groups,dc=root,dc=sololab))"
  }
  groups = {
    ou     = "ou=Groups,dc=root,dc=sololab"
    filter = "(&(objectClass=groupOfUniqueNames)(cn=App-*))"
  }
}
