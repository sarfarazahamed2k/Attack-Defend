variable "microsoft_entra_connect" {
  description = "Microsoft Entra Connect service account configuration"
  type = object({
    user_principal_name = string
    display_name        = string
    password           = string
  })
}

