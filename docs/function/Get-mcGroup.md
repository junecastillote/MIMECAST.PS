# Get-mcGroup

Get all or top *n* groups from the Mimecast directory.

## Table of Contents<!-- omit in toc -->

- [SYNTAX](#syntax)
- [PARAMETERS](#parameters)
- [EXAMPLES](#examples)
  - [Example 1: Exporting All Mimecast Groups to CSV](#example-1-exporting-all-mimecast-groups-to-csv)
  - [Example 2: Getting the Top N Mimecast Groups](#example-2-getting-the-top-n-mimecast-groups)
- [Response Object](#response-object)
  - [Sample Output](#sample-output)
  - [Properties](#properties)
- [References](#references)

## SYNTAX
```powershell
Get-mcGroup `
    [-accessKey] <securestring>  `
    [-secretKey] <securestring> `
    [-appId] <securestring> `
    [-appKey] <securestring> `
    [[-Region] <string>] `
    [[-TopResult] <int>] `
    [<CommonParameters>]
```

## PARAMETERS

* `-appId`

  The **Application ID** value of your Mimecast registered application. This parameter is mandatory and must be a **secure string** object.

* `-accessKey`

  The Access Key value of your Mimecast registered application. This parameter is mandatory and must be a **secure string** object.

* `-secretKey`

  The Secret Key value of your Mimecast registered application. This parameter is mandatory and must be a **secure string** object.

* `-appKey`

  The Application Key value of your Mimecast registered application. This parameter is mandatory and must be a **secure string** object.

* `-Region`

  Your Mimecast region. The valid regions are `eu`, `de`, `us`, `ca`, `za`, `au`, `offshore`. If not specified, the default value is `us`.

* `-TopResult`

  Limits the number of groups to return. This parameter is optional. For example, if you want to get only the first five (5) groups, specify `-TopResult 5`. If not specified, all groups will be returned.

## EXAMPLES

### Example 1: Exporting All Mimecast Groups to CSV

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

Get-mcGroup @keys | Export-Csv .\mimecast_groups.csv -NoTypeInformation
```

### Example 2: Getting the Top N Mimecast Groups

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

# Get the first N groups only
$top_n_groups = Get-mcGroup @keys -TopResult 5
```

## Response Object

### Sample Output

```
id          : eNodzk0LgjAYAOD...
description : Mimecast group name
parentId    : eNoVzk0LgjAYAOD...
userCount   : 17
folderCount : 0
```

### Properties

* `id` - The group's identity string.
* `description` - The group's name.
* `source` - The Mimecast source for the group information.
* `parentId` - The group's parent folder identity string.
* `usercount` - The number of group members.
* `folderCount` - The number of sub-folders / sub-groups.

## References

* [Find-Groups (Mimecast API)](https://integrations.Mimecast.com/documentation/endpoint-reference/directory/find-groups/).
* [About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting)