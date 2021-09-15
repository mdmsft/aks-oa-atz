param subnetId string
param diskName string

var segments = split(subnetId, '/')

var serviceCidr = '10.100.2.0'

var serviceOctals = split(serviceCidr, '.')

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: segments[8]
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: last(segments)
  parent: vnet
}

resource disk 'Microsoft.Compute/disks@2020-12-01' existing = {
  name: diskName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'aks'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.21.2'
    dnsPrefix: 'aks'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: '${serviceCidr}/24'
      dnsServiceIP: '${serviceOctals[0]}.${serviceOctals[1]}.${serviceOctals[2]}.10'
    }
  }
}

var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource rbacNetwork 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(aksCluster.id, networkContributorRoleId)
  scope: subnet
  properties: {
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
  }
}

var virtualMachineContributorRoleId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource rbacVirtualMachine 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(aksCluster.id, virtualMachineContributorRoleId)
  scope: disk
  properties: {
    principalId: aksCluster.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', virtualMachineContributorRoleId)
  }
}

output name string = aksCluster.name
