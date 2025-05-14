location="Australia Central"
admin_username = "user_administrator"
admin_password = "VLYqE5M2TaU6XNEM7y9bbk2p2equIJqxy2uGISXUTOQCYJSx8d"

domain_name         = "csrp.local"
domain_controller_ip = "10.0.1.4"
domain_admin        = "Administrator"
domain_admin_password = "w3qArctaT5YMRFiKVuFSSsk8B8RyLaOXCKJ67aLJmTgrG3oaUR"
safe_mode_password   = "uumQ0Z4c0Z5eh623p9zYyJqR8AnOo7JtUkmt7kGuJSCNDZRiQ7"
netbios_name        = "CSRP"
workstation_hostname = "workstation-1"

scenario1_users = [
  {
    username     = "RalphMay"
    description  = ""
    display_name = "Ralph May"
    password     = "iMjnrDbBRhdNClZz4VArE2fM5XrJiHVPjOZDJ1YkBN0EmzuM9X"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Users"]
  },
  {
    username     = "WadeWells"
    description  = ""
    display_name = "Wade Wells"
    password     = "3BTX9oJOMrlbiDZGdO676657OYS9iwATfMUiSaJmCPiBTfgwtY"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Admins"]
  }
]

scenario2_users = [
  {
    username     = "CoreyHam"
    description  = ""
    display_name = "Corey Ham"
    password     = "03oMKu7awDNwX9cb8ckrL0U0BSrD8KbVaM8N1irDVsMgf0EW9l"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Users"]
  }
]

scenario3_users = [
  {
    username     = "JeffMcJunkin"
    description  = ""
    display_name = "Jeff McJunkin"
    password     = "o23VHyzlL1tjKJ86DhFSj9OzqKXq1ttIESoizQKyPSxomMtOeh"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Users"]
  },
  {
    username     = "JeffMcJunkinAdmin"
    description  = "p9aJ2NTjBCCWj1R1Du8UjbxI9H85xUU5A5rp96UeFsnuKae5AZ"
    display_name = "Jeff McJunkin Admin"
    password     = "p9aJ2NTjBCCWj1R1Du8UjbxI9H85xUU5A5rp96UeFsnuKae5AZ"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Admins"]
  }
]

scenario4_users = [
  {
    username     = "TimMedin"
    description  = ""
    display_name = "Tim Medin"
    password     = "wbPLNHLZoZ4UpqOR2QFo5pDrTtcV8Hw5ba20qqsb8MHrGe7Sww"
    ou           = "CN=Users,DC=csrp,DC=local"
    groups       = ["Domain Users"]
  }
]

spn_users = [
  {
    display_name = "SQL Service Account"
    username     = "MSSQLSvc"
    password     = "vMFWrFgHLv4Up76dFuHV8GDooVeaw675UwslKYKRIUFkh9WjQy"
    ou           = "CN=Users,DC=csrp,DC=local"
    mssql_spn    = "MSSQLSvc/csrp-dc.csrp.local"
  }
]

entra_connect_config = {
  username     = "EntraConnectUser"
  display_name = "Microsoft Entra Connect User"
  password     = "ppBkFFW74TKUpBfQ9K5MfvQ3Xn7GiYnF53gdJ3POaQVzNEjdus"
}


scenario1_config = {
  users               = ["csrp\\\\RalphMay"]
  group               = "Administrators"
  chrome_installer_url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
  temp_path           = "C:\\\\chrome_installer.exe"
}

scenario2_config = {
  users = ["csrp\\\\CoreyHam"]
  group = "Administrators"
}

scenario3_config = {
  users                           = ["csrp\\\\JeffMcJunkin"]
  group                           = "Administrators"
  decoy_username                  = "JeffMcJunkinAdmin"
  unconstrained_delegation_username = "JeffMcJunkin"
  service_principal_name            = "svc-web-backend"
}

scenario4_config = {
  users = ["csrp\\\\TimMedin"]
  group = "Administrators"
}

microsoft_entra_connect = {
    user_principal_name = "AzureConnect"
    display_name        = "Azure Connect"
    password            = "jEu2EXzgezHwNlWeDxNJPBurqmd4HhxqJFdryMQdhz88Tbr5Kv"
}

scenario1_entra_user = {
    user_principal_name = "JoffThyer"
    display_name        = "Joff Thyer"
    password            = "GsPfyhN76bdxYMi1GPifxr2VfUQxV5N8kOSaM62VtgtAFfTCk2"
}

scenario2_entra_user = {
    user_principal_name = "JohnStrand"
    display_name        = "John Strand"
    password            = "7hEKNrbV0e2zxJ6SiPu6d5PRUfu4eaCQjtvUWPr5EPFmp19y4i"
}

scenario2_entra_decoy_user = {
    user_principal_name = "JohnStrandAdmin"
    display_name        = "John Strand Admin"
    password            = "fKHPa8e36ezY716w4mfTFmNGPF6K0GfCweQ0HZuvOHZRNdQPxe"
}

scenario4_entra_decoy_user = {
    user_principal_name = "BeauBullock"
    display_name        = "Beau Bullock"
    password            = "oxRBNXJ7M6H7kzvAv1qXEdWp0A0IKsikwF4rMyc8PVW9A7tHB3"
}

