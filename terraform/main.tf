module "on_premise" {
    source = "./on-premise"
    location       = var.location
    admin_username = var.admin_username
    admin_password = var.admin_password
    ssh_public_key = var.ssh_public_key
    domain_name           = var.domain_name
    domain_controller_ip  = var.domain_controller_ip
    domain_admin         = var.domain_admin
    domain_admin_password = var.domain_admin_password
    safe_mode_password   = var.safe_mode_password
    netbios_name        = var.netbios_name
    workstation_hostname = var.workstation_hostname
    scenario1_users = var.scenario1_users
    scenario2_users = var.scenario2_users
    scenario3_users = var.scenario3_users
    scenario4_users = var.scenario4_users
    spn_users       = var.spn_users
    entra_connect_config = var.entra_connect_config
    scenario1_config = var.scenario1_config
    scenario2_config = var.scenario2_config
    scenario3_config = var.scenario3_config
    scenario4_config = var.scenario4_config
}

module "red" {
    source = "./red"
    location       = var.location
    admin_username = var.admin_username
    admin_password = var.admin_password
    ssh_public_key = var.ssh_public_key

}

resource "null_resource" "copy_inventory" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/inventory.ini /workspace/ansible/inventory.ini"
    }
}

resource "null_resource" "copy_inventory_dc" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/dc.yml /workspace/ansible/host_vars/dc.yml"
    }
}

resource "null_resource" "copy_inventory_workstation" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/workstation.yml /workspace/ansible/host_vars/workstation.yml"
    }
}

resource "null_resource" "copy_inventory_red" {
    depends_on = [module.red]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/red/inventory_red.ini /workspace/ansible/inventory_red.ini"
    }
}

resource "null_resource" "copy_inventory_scenario1" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/scenario-1.yml /workspace/ansible/scenario_vars/scenario-1.yml"
    }
}

resource "null_resource" "copy_inventory_scenario2" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/scenario-2.yml /workspace/ansible/scenario_vars/scenario-2.yml"
    }
}

resource "null_resource" "copy_inventory_scenario3" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/scenario-3.yml /workspace/ansible/scenario_vars/scenario-3.yml"
    }
}

resource "null_resource" "copy_inventory_scenario4" {
    depends_on = [module.on_premise]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/on-premise/scenario-4.yml /workspace/ansible/scenario_vars/scenario-4.yml"
    }
}

module "microsoft_entra_connect" {
    source = "./cloud/MicrosoftEntraConnect"
    location       = var.location
    microsoft_entra_connect = var.microsoft_entra_connect
}

module "scenario1" {
    depends_on = [null_resource.copy_inventory_scenario1]
    source = "./cloud/Scenario-1"
    location = var.location
    scenario1_entra_user = var.scenario1_entra_user
}

module "scenario2" {
    depends_on = [null_resource.copy_inventory_scenario2]
    source = "./cloud/Scenario-2"
    location = var.location
    netbios_name           = var.netbios_name
    scenario2_entra_user = var.scenario2_entra_user
    scenario2_entra_decoy_user = var.scenario2_entra_decoy_user
}

resource "null_resource" "ansible_config" {
    depends_on = [null_resource.copy_inventory]
    provisioner "local-exec" {
        command     = "ansible-playbook -i inventory.ini playbook-configure-setup.yml | tee /workspace/ansible/output_on-premise.log"
        working_dir = "../ansible"
    }
}

# resource "null_resource" "ansible_config_red" {
#     depends_on = [null_resource.copy_inventory_red]
#     provisioner "local-exec" {
#         command     = "ansible-playbook -i inventory_red.ini playbook-configure-attackvm.yml"
#         working_dir = "../ansible"
#     }
# }

variable "continue_execution" {
  type        = string
  description = "Enter 'yes' to continue with post manual setup or any other value otherwise"
}

module "scenario3" {
    count  = var.continue_execution == "yes" ? 1 : 0
    source = "./cloud/Scenario-3"
    scenario3_users = var.scenario3_users
}

module "scenario4" {
    count  = var.continue_execution == "yes" ? 1 : 0
    source = "./cloud/Scenario-4"
    location = var.location
    admin_username = var.admin_username
    admin_password = var.admin_password
    ssh_public_key = var.ssh_public_key
    scenario4_entra_decoy_user = var.scenario4_entra_decoy_user
    spn_users = var.spn_users
}

resource "null_resource" "copy_inventory_webapp" {
    count  = var.continue_execution == "yes" ? 1 : 0
    depends_on = [module.scenario4]
    provisioner "local-exec" {
        command = "cp /workspace/terraform/cloud/Scenario-4/inventory_webapp.ini /workspace/ansible/inventory_webapp.ini"
    }
}

resource "null_resource" "ansible_config_webapp" {
    count  = var.continue_execution == "yes" ? 1 : 0
    depends_on = [null_resource.copy_inventory_webapp]
    provisioner "local-exec" {
        command     = "ansible-playbook -i inventory_webapp.ini playbook-configure-webapp.yml"
        working_dir = "../ansible"
    }
}
