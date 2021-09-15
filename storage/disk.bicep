resource disk 'Microsoft.Compute/disks@2020-12-01' = {
  name: 'disk'
  location: resourceGroup().location
  sku: {
    name: 'StandardSSD_LRS'
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 4
  }
}

output id string = disk.id
output name string = disk.name
