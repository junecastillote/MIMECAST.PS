Function New-mcGroupBackup {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $accessKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $secretKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $appId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [SecureString]
        $appKey,

        [Parameter()]
        [ValidateSet('eu', 'de', 'us', 'ca', 'za', 'au', 'offshore')]
        [string]
        $Region = 'us',

        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputDirectory = $(
            if (isWindows) {
                    ([System.IO.Path]::Combine($(Resolve-Path $Env:HOMEPATH), 'mimecastDotPS', 'backup'))
            }
            else {
                    ([System.IO.Path]::Combine($(Resolve-Path $Env:HOME), 'mimecastDotPS', 'backup'))
            }
        ),

        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $TranscriptDirectory = $(
            if (isWindows) {
                    ([System.IO.Path]::Combine($(Resolve-Path $Env:HOMEPATH), 'mimecastDotPS', 'logs'))
            }
            else {
                    ([System.IO.Path]::Combine($(Resolve-Path $Env:HOME), 'mimecastDotPS', 'logs'))
            }
        ),

        [Parameter()]
        [int]
        $TopResult,

        [Parameter()]
        [ValidateSet('Zip+Delete', 'Zip+DoNotDelete', 'DoNotZip')]
        [string]
        $BackupType = 'Zip+Delete',

        [Parameter()]
        [switch]
        $SendEmail,

        [Parameter()]
        [string]
        $From,

        [Parameter()]
        [string[]]
        $To,

        [Parameter()]
        [string[]]
        $Cc,

        [Parameter()]
        [string[]]
        $Bcc
    )

    if ($SendEmail -and !$To) {
        SayError "The -To parameter is required to enable sending email notification."
        return $null
    }

    if (($To -or $Cc -or $Bcc) -and !$SendEmail  ) {
        SayError "Use the -SendEmail switch To enable sending email notification."
        return $null
    }

    # Create the API keys splat
    $keySplat = @{
        accessKey = $accessKey
        secretKey = $secretKey
        appId     = $appId
        appKey    = $appKey
    }
    # Set the filenames' suffix as the current datetime
    $dateNow = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $transcriptFile = "$TranscriptDirectory\transcript_$dateNow.log"

    # Start transcript
    LogStart $transcriptFile
    SayInfo "Transcript directory is @$($TranscriptDirectory)"

    # Test if output directory exists. Create if not. Exit if error.
    try {
        if (!(Test-Path $OutputDirectory)) {
            $newDir = New-Item -ItemType Directory -Path $OutputDirectory -Force -ErrorAction Stop
            $OutputDirectory = $newDir.FullName
        }
        else {
            $OutputDirectory = (Resolve-Path $OutputDirectory).Path
        }

        SayInfo "Output directory is @$($OutputDirectory)"

        # Set the output filenames
        $mimecastGroupsFile = "$OutputDirectory\mimecastGroups_$dateNow.csv"
        $mimecastGroupMembersFile = "$OutputDirectory\mimecastGroupMembers_$dateNow.json"
        $mimecastBackupFile = "$OutputDirectory\mimecastBackup_$dateNow.zip"
    }
    catch {
        $errMessage = "There was an error creating the output folder [$($OutputDirectory)]. Specify a different folder or manually create the folder first and try again. Exception message: [$($_.Exception.Message)]"
        SayError $errMessage
        LogEnd
        return $null
    }

    # Get Mimecast account information
    $mimecastAccount = Get-mcAccount @keySplat

    # Get all groups from the Mimecast directory
    try {
        if ($TopResult) {
            $mcGroup = Get-mcGroup @keySplat -TopResult $TopResult -ErrorAction Stop
        }
        else {
            $mcGroup = Get-mcGroup @keySplat -ErrorAction Stop
        }
        $mcGroup | Export-Csv $mimecastGroupsFile -NoTypeInformation -Force
    }
    catch {
        $errMessage = "There was an error getting the Mimecast groups. Review the error for reference. Exception message: [$($_.Exception.Message)]"
        SayError $errMessage
        LogEnd
        return $null
    }

    # Export members of all groups
    try {
        $mcGroupMembers = Get-mcGroupMember @keySplat -GroupObject $mcGroup -ErrorAction STOP
        # Export, JSON recommended.
        $mcGroupMembers | ConvertTo-Json -Depth 4 | Out-File $mimecastGroupMembersFile -Force
    }
    catch {
        $errMessage = "There was an error getting exporting the group members. Review the error for reference. Exception message: [$($_.Exception.Message)]"
        SayError $errMessage
        LogEnd
        return $null
    }

    # Compress
    try {
        switch ($BackupType) {
            'Zip+Delete' {
                SayInfo "Compressing output files to $($mimecastBackupFile)."
                Compress-Archive -Path @($mimecastGroupsFile, $mimecastGroupMembersFile) -DestinationPath $mimecastBackupFile -Force -ErrorAction Continue
                Start-Sleep -Seconds 3
                SayInfo "Deleting output files after compression."
                Remove-Item -Path @($mimecastGroupsFile, $mimecastGroupMembersFile) -Force
            }
            'Zip+DoNotDelete' {
                SayInfo "Compressing output files to $($mimecastBackupFile)."
                Compress-Archive -Path @($mimecastGroupsFile, $mimecastGroupMembersFile) -DestinationPath $mimecastBackupFile -Force -ErrorAction Continue
            }
            Default {}
        }
    }
    catch {
        $errMessage = "There was an error compressing the output files. Review the error for reference. Exception message: [$($_.Exception.Message)]"
        SayError $errMessage
        LogEnd
        return $null
    }

    if ($SendEmail) {
        $thisModule = Get-ThisModule
        $mailBody = @(
            "The Mimecast groups backup has completed for the $($mimecastAccount.data.accountName) account.<br/>",
            "You can find the backup files at:<br>",
            "<ul><li>Backup location: $($OutputDirectory)</li><li>Transcript location: $($TranscriptDirectory)</ul><br/><br/>",
            "<a href=""$($thisModule.PrivateData.PSData.ProjectUri)"">$($thisModule.Name.ToUpper()) v$($thisModule.Version.ToString())</a>"
        )
        $mailSplat = @{
            To      = $To
            Subject = "$($mimecastAccount.data.accountName) | Mimecast group backup notification"
            Body    = $($mailBody -join "`n")
        }

        if ($Cc) { $mailBody += @{Cc = $Cc } }
        if ($Bcc) { $mailBody += @{Cc = $Bcc } }

        Send-mcMailMessage @keySplat @mailSplat
    }
    LogEnd
}