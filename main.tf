terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.48.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

terraform{
  backend "azurerm" {
    resource_group_name = "terraform_rg_blobstore"
    storage_account_name = "dostoretf"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}

variable "imagebuild" {
  type        = string
  description = "Latest Image Build"
}

resource "azurerm_resource_group" "tf_test" {
  name = "tfmainrg"
  location = "Australia East"

  tags={
    environment ="terraform demo"
  }
}

resource "azurerm_virtual_network" "myterraformnetwork"{
  name ="terraformVnet"
  address_space =["10.0.0.0/16"]
  location = "Australia East"
  resource_group_name = azurerm_resource_group.tf_test.name

  tags={
    environment ="terraform demo"
  }
}

resource "azurerm_subnet" "myterraformsubnet"{
  name ="terraformSubnet"
  resource_group_name = azurerm_resource_group.tf_test.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes  = ["10.0.1.0/24"]
}

resource "azurerm_container_group" "terraform_test" {
  name                      = "weatherapi"
  location                  = azurerm_resource_group.tf_test.location
  resource_group_name       = azurerm_resource_group.tf_test.name

  ip_address_type     = "public"
  dns_name_label      = "karlatdataoriented"
  os_type             = "Linux"

  container {
      name            = "weatherapi"
      image           = "karlatdataoriented/weatherapi:${var.imagebuild}"
        cpu             = "1"
        memory          = "1"

        ports {
            port        = 80
            protocol    = "TCP"
        }
  }
}