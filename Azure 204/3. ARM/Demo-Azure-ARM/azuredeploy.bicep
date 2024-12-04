param location string = resourceGroup().location

param storageAccountName string = 'armdemostorage08072023'

module storageAccount 'storageAccount.bicep' = {
  name: 'storage_account'
  params:{
    storageAccountName: storageAccountName
    location: location
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'manu-idenity'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'contributor')
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentscript'
  location: location
  kind: 'AzurePowerShell'
  dependsOn:[
    storageAccount
  ]
  identity:{
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: '''
    $output = 'Hello world'
    Write-Output $output
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['text'] = $output
    '''
    retentionInterval: 'PT1H'
  }
}
output accountName string = storageAccountName
output scriptResult string = deploymentScript.properties.outputs.text
