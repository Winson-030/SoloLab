variable "hyperv_host" {
  type    = string
  default = "127.0.0.1"
}

variable "hyperv_user" {
  type = string
}

variable "hyperv_password" {
  type = string
}

variable "vm_name" {
  type    = string
  default = null
}

variable "source_disk" {
  type    = string
  default = null
}

variable "data_disk_path" {
  type    = string
  default = "value"
}
