# Get-mcGroupMember

Get the members of the Mimecast groups.

## Table of Contents<!-- omit in toc -->

- [SYNTAX](#syntax)
- [PARAMETERS](#parameters)
- [EXAMPLES](#examples)
  - [Example 1: Get the Members of a Mimecast Group ID](#example-1-get-the-members-of-a-mimecast-group-id)
  - [Example 2: Get the Members of one or more Mimecast Group Objects](#example-2-get-the-members-of-one-or-more-mimecast-group-objects)
- [Response Object](#response-object)
  - [Sample Output](#sample-output)
  - [Properties](#properties)
- [References](#references)

## SYNTAX

```powershell
Get-mcGroupMember `
    -GroupID <string[]> `
    -accessKey <securestring> `
    -secretKey <securestring> `
    -appId <securestring> `
    -appKey <securestring> `
    [-Region <string>] `
    [-PageSize <int>] `
    [<CommonParameters>]
```

```powershell
Get-mcGroupMember `
    -GroupObject <string[]> `
    -accessKey <securestring> `
    -secretKey <securestring> `
    -appId <securestring> `
    -appKey <securestring> `
    [-Region <string>] `
    [-PageSize <int>] `
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

  The list or array of group IDs to backup.

  > Do not use together with the `-GroupObject` parameter.

* `-GroupObject`

  One or more Mimecast group objects. The group object is the result of the `Get-mcGroup` function.

  > Do not use together with the `-GroupID` parameter.

## EXAMPLES

### Example 1: Get the Members of a Mimecast Group ID

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

# Group ID
$groupId = "group ID"

# Get group members
$mcGroupMember = Get-mcGroupMember @keys -GroupId $groupId
```

### Example 2: Get the Members of one or more Mimecast Group Objects

This example first runs the [`Get-mcGroup`](Get-mcGroup.md) to get the Mimecast group objects and store them into a variable. You can also run the [`Get-mcGroupById`](Get-mcGroupById.md) command instead.

Then runs the `Get-mcGroupMember` command to get the members of group objects in positions 8,9 and 10.

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

# Group all groups
$groups = Get-mcGroup @keys

# Get group members of group objects in index 8,9,10
$mcGroupMember = Get-mcGroupMember @keys -GroupObject $groups[8..10]
```

## Response Object

### Sample Output

```
groupName         : Test Group 1
groupID           : eNoVzk0LgjAYAOD_8l4TbJnOhA5WWBZ9gFYKXnR7R4ambbqi6L9X9....
totalMembersCount : 5
groupMembers      : { @{emailAddress=user1@domain.com; name=User 1; internal=True; domain=domain.com; type=created_by_email}...}
```

### Properties

* `groupName` - The group's name. This value is not unique. There can be duplicate group names.
* `groupId` - The unique group identifier string.
* `totalMembersCount` - The total group member count.
* `groupMembers` - The array list of each group members.
  * `emailAddress` - The group member's email address.
  * `name` - The group member's name.
  * `domain` - The group member's email domain.
  * `type` - The description of how the members were created or added as a member of the group.

> As you can see, this output is not flat and has nested properties, so do not export this list into a CSV file. Instead, consider exporting to JSON, XML, or YAML formats.

## References

* [Get-Group-Members (Mimecast API)](https://integrations.Mimecast.com/documentation/endpoint-reference/directory/get-group-members/)
* [About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting)