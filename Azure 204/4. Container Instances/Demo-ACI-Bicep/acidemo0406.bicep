param resourceName string
param location string = resourceGroup().location

resource container 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: resourceName
  location: location
  properties: {
    containers: [
      {
        name:resourceName
        properties:{
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld'
          ports:[
            {
              port:80
              protocol:'TCP'
            }
          ]
          resources:{
            requests:{
              cpu:1
              memoryInGB:2
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy:'Always'
    ipAddress:{
      type:'Public'
      ports:[
        {
          port:80
          protocol:'TCP'
        }
      ]
    }
  }
}

output containerIP string = container.properties.ipAddress.ip
