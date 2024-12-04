param resourceName string
param location string = resourceGroup().location

resource container 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: resourceName
  location:location
  properties: {
    containers: [
      {
        name: 'hello-world'
        properties:{
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          ports:[
            {port:80}
            {port:8080}
          ]
          resources:{
            requests:{
              cpu:1
              memoryInGB:2
            }
          }
        }
      }
      {
        name: 'sidecar'
        properties:{
          image: 'mcr.microsoft.com/azuredocs/aci-tutorial-sidecar'
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
    ipAddress: {
      type:'Public'
      ports:[
        {
          port:80
          protocol:'TCP'
        }
        {
          port:8080
          protocol:'TCP'
        }
      ]
    }
  }
}

output containerIP string = container.properties.ipAddress.ip
