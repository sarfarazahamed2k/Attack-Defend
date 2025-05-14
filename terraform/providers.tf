terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "4.20.0"
        }

        azuread = {
            source = "hashicorp/azuread"
            version = "3.1.0"
        }

        local = {
            source = "hashicorp/local"
            version = "2.5.2"
        }

        tls = {
            source  = "hashicorp/tls"
            version = "4.0.6"
        }

        time = {
            source = "hashicorp/time"
            version = "0.12.1"
        }
    }
    backend "local" {
        path = "terraform.tfstate"
    }
}

provider "azurerm" {
    features {
        resource_group {
            prevent_deletion_if_contains_resources = false
        }
        virtual_machine {
            skip_shutdown_and_force_delete = true
        }
        key_vault {
            purge_soft_delete_on_destroy    = false
            recover_soft_deleted_key_vaults = false
        }
        log_analytics_workspace {
            permanently_delete_on_destroy = true
        }
    }
}

provider "azuread" {}

provider "local" {}

provider "time" {}
