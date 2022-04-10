# New-mcGroupBackup

Export the Mimecast groups to CSV and the group members to JSON.

## Table of Contents<!-- omit in toc -->

- [SYNTAX](#syntax)
- [PARAMETERS](#parameters)
- [EXAMPLES](#examples)
  - [Example 1: Create a backup of ALL groups and group members](#example-1-create-a-backup-of-all-groups-and-group-members)
- [Sample Output](#sample-output)
- [References](#references)

## SYNTAX

```powershell
New-mcGroupBackup `
    [-accessKey] <securestring> `
    [-secretKey] <securestring> `
    [-appId] <securestring> `
    [-appKey] <securestring> `
    [[-Region] <string>] `
    [[-OutputDirectory] <string>] `
    [[-TranscriptDirectory] <string>] `
    [[-TopResult] <int>] `
    [[-BackupType] <string>] `
    [[-From] <string>] `
    [[-To] <string[]>] `
    [[-Cc] <string[]>] `
    [[-Bcc] <string[]>] `
    [-SendEmail] `
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

* `-OutputDirectory`

  (OPTIONAL) The directory where the output files will be saved. The output files will be a CSV file for the list of groups and a JSON file containing all group and group members.

  If not specified, the default destination path is `[user_profile]\mimecastDotPs\backup`.

* `-TranscriptDirectory`

  The directory where to save the transcript logs.
  If not specified, the default destination path is `[user_profile]\mimecastDotPs\logs`

* `-BackupType`

  (OPTIONAL) Specifies the type of output to produce. The valid values are:

  * `Zip+Delete` - This will zip the output files and delete the original CSV and JSON files.
  * `Zip+DoNotDelete` - This will zip the output files and retain the original CSV and JSON files.
  * `DoNotZip` - This will NOT create a zip file. The CSV and JSON files will serve as your backup and can be large in size.

  If you do not specify the backup type, the default backup type is `Zip+Delete`.

* `-SendEmail`

  (OPTIONAL) Use this switch to enable sending the group backup notification email. If this is not specified, the succeeding email-related parameters will be ignored.

* `-From`

  (OPTIONAL) Specifies the sender's email address. If not specified, the default email address is the one associated with the authentication profile used.

* `-To`

  (REQUIRED) Specifies one (single string) or more (array) TO recipients' email addresses.

* `-Cc`

  (OPTIONAL) Specifies one (single string) or more (array) CC recipients' email addresses.

* `-Bcc`

  (OPTIONAL) Specifies one (single string) or more (array) BCC recipients' email addresses.

## EXAMPLES

### Example 1: Create a backup of ALL groups and group members

To create a backup of all groups and members and send an email notification.

```PowerShell
# Create the confidential keys splat
$keys = @{
    appId = "secure application id"
    accessKey = "secure access key"
    secretKey = "secure secret key"
    appKey = "secure application key"
}

# Create the email splat
$mail = @{
    SendEmail = $true
    To = @('june.castillote@gmail.com')
    Cc = @('someone_else_to_bother@poshlab.ga','security@lzex.ml')
    Bcc = @('confidential_informant@crazyadmins365.ga')
}

# Create the backup settings
$backup = @{
    #$OutputDirectory = ""
    #TranscriptDirectory = ""
    BackupType = 'Zip+Delete'
}

New-mcGroupBackup @keys @mail
```

## Sample Output

![Sample Email](images/email-sample.png)

## References

* [Send-Email (Mimecast API)](https://integrations.Mimecast.com/documentation/endpoint-reference/email/send-email/)
* [About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting)