param resourceName string
param location string = resourceGroup().location
param sku string = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: resourceName
  location: location
  sku: {
    name: sku
  }
  properties:{
    adminUserEnabled: true
  }
}

output registryName string = containerRegistry.name
output registryLoginServer string = containerRegistry.properties.loginServer
