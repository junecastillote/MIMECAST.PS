# Get-mcGroupById

Get the group information with the specific group ID.

## Table of Contents<!-- omit in toc -->

- [SYNTAX](#syntax)
- [PARAMETERS](#parameters)
- [EXAMPLES](#examples)
  - [Example 1: Get a Specific Group Information](#example-1-get-a-specific-group-information)
  - [Example 2: Getting the Top N Mimecast Groups](#example-2-getting-the-top-n-Mimecast-groups)
- [Response Object](#response-object)
  - [Sample Output](#sample-output)
  - [Properties](#properties)
- [References](#references)

## SYNTAX
```powershell
Get-mcGroupById `
    [-GroupID] <string> `
    [-accessKey] <securestring> `
    [-secretKey] <securestring> `
    [-appId] <securestring> `
    [-appKey] <securestring> `
    [[-Region] <string>] `
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

* `-GroupID`

  The specific Mimecast group ID to get. This parameter is mandatory.

## EXAMPLES

### Example 1: Get a Specific Group Information

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

Get-mcGroupById @keys -GroupId 'group id'
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
```

## Response Object

### Sample Output

```
id          : eNoVzk1vgjAYAOD...
description : Mimecast group 1
source      : cloud
parentId    : eNoVzsFugjAYAOB...
userCount   : 2
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

* [About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting)