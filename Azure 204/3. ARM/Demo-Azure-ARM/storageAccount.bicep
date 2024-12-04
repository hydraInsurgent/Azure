param location string = resourceGroup().location

param storageAccountName string = 'armdemostorage08072023'

var tables = [
  'table1'
  'table2'
]
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  //location: 'EastUs'  - This gives error because Microsoft suggestts that a resource location should not use a hard-coded string or variable value. Please use a parameter value, an expression, or the string 'global'.
  location: location
  tags:{
    environment: 'dev'
    buisness_unit: 'connectivity'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource storageAccountTableServices 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource storageAccountTables 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-09-01' = [ for table in tables : {
  name: table
  parent: storageAccountTableServices
}]
