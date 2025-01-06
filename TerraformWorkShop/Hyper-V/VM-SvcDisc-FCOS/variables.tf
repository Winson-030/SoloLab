variable "prov_hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "vm" {
  type = object({
    count = number
    name  = string
    vhd = object({
      dir    = string
      source = string
      data_disk_ref = object({
        backend = string
        config  = map(string)
      })
    })
    nic = list(object({
      name                = string
      switch_name         = string
      dynamic_mac_address = optional(bool, null)
      static_mac_address  = optional(string, null)
    }))
    enable_secure_boot = optional(string, "On")
    memory = object({
      startup_bytes = number
      maximum_bytes = number
      minimum_bytes = number
    })
  })
}

variable "butane" {
  type = object({
    files = object({
      base   = string
      others = optional(list(string), null)
    })
    vars = map(string)
  })
}

variable "prov_pdns" {
  type = object({
    api_key        = string
    server_url     = string
    insecure_https = optional(bool, null)
  })
}

variable "dns_record" {
  type = object({
    zone    = string
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  })
}
