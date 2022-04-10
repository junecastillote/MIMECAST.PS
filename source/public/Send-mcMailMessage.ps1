#TODO:
# * Add function for email attachment (https://integrations.Mimecast.com/documentation/endpoint-reference/email/file-upload/)
Function Send-mcMailMessage {
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

        [Parameter()]
        [string]
        $From,

        [Parameter(Mandatory)]
        [string[]]
        $To,

        [Parameter()]
        [string[]]
        $Cc,

        [Parameter()]
        [string[]]
        $Bcc,

        [Parameter(Mandatory)]
        [string]
        $Subject,

        [Parameter(Mandatory)]
        [string]
        $Body
    )

    # Create the API keys splat
    $keySplat = @{
        accessKey = $accessKey
        secretKey = $secretKey
        appId     = $appId
        appKey    = $appKey
    }

    #Setup required variables
    $baseUrl = "https://$Region-api.Mimecast.com"
    if ($Region -eq 'offshore') {
        $baseUrl = "https://je-api.Mimecast.com"
    }
    $uri = "/api/email/send-email"
    $url = $baseUrl + $uri

    $requestId = [guid]::NewGuid().guid
    $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri

    Function ConvertTo-HashRecipient {
        param(
            [Parameter(Mandatory)]
            [string[]]
            $Recipients
        )
        [array]$hashRecipients = @()
        $Recipients | ForEach-Object {
            $hashRecipients += @{emailAddress = $_ }
        }
        return $hashRecipients
    }

    $thisModule = Get-ThisModule

    # Compose the message object
    $postBody = @{
        data = @(
            @{
                to           = @($(ConvertTo-HashRecipient $To))
                subject      = $($Subject)
                htmlBody     = @{content = $($Body) }
                extraHeaders = @(@{
                        name  = 'X-Mailer'
                        value = "$($thisModule.Name) v$($thisModule.Version.ToString())"
                    })
            }
        )
    }

    if ($From) {
        $postBody.data[0] += @{
            from = @{
                emailAddress = $From
            }
        }
    }

    if ($Cc) {
        $postBody.data[0] += @{
            cc = @{
                emailAddress = $From
            }
        }
    }

    if ($Bcc) {
        $postBody.data[0] += @{
            bcc = @{
                emailAddress = $From
            }
        }
    }

    # Send the message
    try {
        $response = Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json -Depth 6)" -Uri $url -ErrorAction STOP
        Say "======================================================================"
        Say "Mail Send Result"
        Say "======================================================================"
        Say ($response | Format-List)

        if ($response.fail) {
            return ($response.fail.errors)
        }
        else {
            return $null
        }
    }
    catch {
        SayError $_.Exception.Message
        return $null
    }
}


