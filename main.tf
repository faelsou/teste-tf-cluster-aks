terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Criação resource group
resource "azurerm_resource_group" "rg_k8s_teste" {
  name     = "rg_k8s_teste"
  location = "Brazil South"
}

# Criação cluster k8s
resource "azurerm_kubernetes_cluster" "teste_k8s" {
  name                = "teste_cluster"
  location            = azurerm_resource_group.rg_k8s_teste.location
  resource_group_name = azurerm_resource_group.rg_k8s_teste.name
  dns_prefix          = "teste-cluster"

  # Definindo tamanho da maquina e tipo   
  default_node_pool {
    name       = "default"
    node_count = "3"
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# output kube_config

output "kube_config" {
  value = azurerm_kubernetes_cluster.teste_k8s.kube_config_raw

  sensitive = true
}

# local file ao adicionar o novo provider usar terraform init = https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file 
# deletei o arquivo kube_config que estava local na minha maquina e inseri o caminho que esta nesta linha
# apos a execução do tf apply conseguimos acessar o cluster usando kubectl get nodes sem precisar das credentials da azure

resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.teste_k8s.kube_config_raw
  filename = "C:\\Users\\rafsouza\\.kube\\config"  
}


