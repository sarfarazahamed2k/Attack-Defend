variable "scenario3_users" {
  description = "Users for scenario 3"
  type = list(object({
    username     = string
    description  = string
    display_name = string
    password     = string
    ou           = string
    groups       = list(string)
  }))
}

