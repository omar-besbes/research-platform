output "principal_id" {
  value = azurerm_kubernetes_cluster.efrei.kubelet_identity[0].object_id
}
