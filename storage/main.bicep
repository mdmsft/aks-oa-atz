targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'aks'
  location: deployment().location
  tags: {
    test: 'true'
  }
}

module disk 'disk.bicep' = {
  name: '${deployment().name}-disk'
  scope: rg
}

module storage 'storage.bicep' = {
  name: '${deployment().name}-storage'
  scope: rg
}

module vnet 'vnet.bicep' = {
  name: '${deployment().name}-vnet'
  scope: rg
}

module aks 'aks.bicep' = {
  name: '${deployment().name}-aks'
  scope: rg
  params: {
    subnetId: vnet.outputs.subnetId
    diskName: disk.outputs.name
  }
}

output commandText string = 'az aks get-credentials -g ${rg.name} -n ${aks.outputs.name}'
output disk object = {
  id: disk.outputs.id
  name: disk.outputs.name
}
output file object = {
  accountName: storage.outputs.accountName
  accountKey: storage.outputs.accountKey
  shareName: storage.outputs.shareName
}
