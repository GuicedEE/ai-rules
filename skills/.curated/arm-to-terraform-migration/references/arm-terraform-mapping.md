# ARM to Terraform Resource Mapping Reference

This document provides comprehensive mappings between Azure ARM template resource types and their Terraform equivalents.

## Compute Resources

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Compute/virtualMachines` | `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` | Choose based on OS |
| `Microsoft.Compute/virtualMachineScaleSets` | `azurerm_linux_virtual_machine_scale_set` or `azurerm_windows_virtual_machine_scale_set` | Choose based on OS |
| `Microsoft.Compute/availabilitySets` | `azurerm_availability_set` | |
| `Microsoft.Compute/disks` | `azurerm_managed_disk` | |
| `Microsoft.Compute/snapshots` | `azurerm_snapshot` | |
| `Microsoft.Compute/images` | `azurerm_image` | |

## Networking Resources

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Network/virtualNetworks` | `azurerm_virtual_network` | |
| `Microsoft.Network/virtualNetworks/subnets` | `azurerm_subnet` | Separate resource in Terraform |
| `Microsoft.Network/networkInterfaces` | `azurerm_network_interface` | |
| `Microsoft.Network/publicIPAddresses` | `azurerm_public_ip` | |
| `Microsoft.Network/networkSecurityGroups` | `azurerm_network_security_group` | |
| `Microsoft.Network/networkSecurityGroups/securityRules` | `azurerm_network_security_rule` | Separate resource in Terraform |
| `Microsoft.Network/loadBalancers` | `azurerm_lb` | |
| `Microsoft.Network/loadBalancers/backendAddressPools` | `azurerm_lb_backend_address_pool` | Separate resource |
| `Microsoft.Network/applicationGateways` | `azurerm_application_gateway` | |
| `Microsoft.Network/routeTables` | `azurerm_route_table` | |
| `Microsoft.Network/privateDnsZones` | `azurerm_private_dns_zone` | |

## Storage Resources

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Storage/storageAccounts` | `azurerm_storage_account` | |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | `azurerm_storage_container` | |
| `Microsoft.Storage/storageAccounts/fileServices/shares` | `azurerm_storage_share` | |
| `Microsoft.Storage/storageAccounts/queueServices/queues` | `azurerm_storage_queue` | |
| `Microsoft.Storage/storageAccounts/tableServices/tables` | `azurerm_storage_table` | |

## Database Resources

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Sql/servers` | `azurerm_mssql_server` | |
| `Microsoft.Sql/servers/databases` | `azurerm_mssql_database` | |
| `Microsoft.Sql/servers/firewallRules` | `azurerm_mssql_firewall_rule` | |
| `Microsoft.DBforPostgreSQL/servers` | `azurerm_postgresql_server` | |
| `Microsoft.DBforMySQL/servers` | `azurerm_mysql_server` | |
| `Microsoft.DocumentDB/databaseAccounts` | `azurerm_cosmosdb_account` | |

## Web & App Services

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Web/serverfarms` | `azurerm_service_plan` | Previously `azurerm_app_service_plan` |
| `Microsoft.Web/sites` | `azurerm_linux_web_app` or `azurerm_windows_web_app` | Choose based on OS |
| `Microsoft.Web/sites/config` | Part of web app resource | Inline configuration |
| `Microsoft.Web/sites/slots` | `azurerm_linux_web_app_slot` | |

## Container Resources

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.ContainerService/managedClusters` | `azurerm_kubernetes_cluster` | AKS |
| `Microsoft.ContainerRegistry/registries` | `azurerm_container_registry` | ACR |
| `Microsoft.ContainerInstance/containerGroups` | `azurerm_container_group` | ACI |

## Security & Identity

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.KeyVault/vaults` | `azurerm_key_vault` | |
| `Microsoft.KeyVault/vaults/secrets` | `azurerm_key_vault_secret` | |
| `Microsoft.KeyVault/vaults/keys` | `azurerm_key_vault_key` | |
| `Microsoft.ManagedIdentity/userAssignedIdentities` | `azurerm_user_assigned_identity` | |

## Monitoring & Management

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.Insights/components` | `azurerm_application_insights` | |
| `Microsoft.OperationalInsights/workspaces` | `azurerm_log_analytics_workspace` | |
| `Microsoft.Insights/metricAlerts` | `azurerm_monitor_metric_alert` | |
| `Microsoft.Insights/activityLogAlerts` | `azurerm_monitor_activity_log_alert` | |

## Messaging & Integration

| ARM Resource Type | Terraform Resource | Notes |
|------------------|-------------------|-------|
| `Microsoft.ServiceBus/namespaces` | `azurerm_servicebus_namespace` | |
| `Microsoft.EventHub/namespaces` | `azurerm_eventhub_namespace` | |
| `Microsoft.EventGrid/topics` | `azurerm_eventgrid_topic` | |

## Common Property Mappings

### Storage Account SKU

| ARM SKU | Terraform Arguments |
|---------|-------------------|
| `Standard_LRS` | `account_tier = "Standard"`, `account_replication_type = "LRS"` |
| `Standard_GRS` | `account_tier = "Standard"`, `account_replication_type = "GRS"` |
| `Standard_RAGRS` | `account_tier = "Standard"`, `account_replication_type = "RAGRS"` |
| `Premium_LRS` | `account_tier = "Premium"`, `account_replication_type = "LRS"` |

### Virtual Machine Size

ARM and Terraform use the same VM size names (e.g., `Standard_D2s_v3`).

### Locations

ARM and Terraform use the same location names (e.g., `eastus`, `westeurope`).

## Expression Conversion Examples

### Parameters

**ARM**:
```json
"[parameters('storageAccountName')]"
```

**Terraform**:
```hcl
var.storage_account_name
```

### Variables

**ARM**:
```json
"[variables('subnetName')]"
```

**Terraform**:
```hcl
local.subnet_name
```

### Concat

**ARM**:
```json
"[concat('prefix-', parameters('name'))]"
```

**Terraform**:
```hcl
"prefix-${var.name}"
```

### Resource ID Reference

**ARM**:
```json
"[resourceId('Microsoft.Network/virtualNetworks', 'myVNet')]"
```

**Terraform**:
```hcl
azurerm_virtual_network.my_vnet.id
```

### Reference

**ARM**:
```json
"[reference(resourceId('Microsoft.Network/publicIPAddresses', 'myIP')).ipAddress]"
```

**Terraform**:
```hcl
azurerm_public_ip.my_ip.ip_address
```

## Notes

1. **Nested Resources**: ARM allows nested resource definitions, but Terraform requires separate resource blocks.

2. **Dependencies**: ARM uses explicit `dependsOn`, while Terraform uses implicit dependencies through attribute references.

3. **Naming**: ARM allows more flexible naming (including dots), while Terraform resources use snake_case identifiers.

4. **API Versions**: ARM requires API versions; Terraform provider handles this internally.

5. **Copy Loops**: ARM's `copy` becomes Terraform's `count` or `for_each`.
