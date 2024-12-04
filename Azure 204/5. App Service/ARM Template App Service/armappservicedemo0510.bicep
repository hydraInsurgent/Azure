param resourceName string
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: resourceName
  location: location
  sku: {
    name: 'F1'
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: resourceName
  location: location
  properties: {
    serverFarmId:appServicePlan.id
  }
  
  resource controls 'sourcecontrols' = {
    name: 'web'
    properties:{
      repoUrl: 'https://github.com/Azure-Samples/html-docs-hello-world'
      branch: 'master'
      isManualIntegration: true
    }
  }
}


