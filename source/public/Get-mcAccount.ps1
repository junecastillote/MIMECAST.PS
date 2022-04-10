#https://integrations.Mimecast.com/documentation/endpoint-reference/account/get-account/
Function Get-mcAccount {
    [cmdletbinding()]
    param(
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
        $Region = 'us'
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
    $uri = "/api/account/get-account"
    $url = $baseUrl + $uri

    $requestId = [guid]::NewGuid().guid
    $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri

    # Create post body
    $postBody = @{
        data = @()
    }

    try {
        $response = @(Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json)" -Uri $url -ErrorAction STOP)
        return $response
    }
    catch {
        $errMessage = "There was an error while getting the Mimecast account data. Exception message: [$($_.Exception.Message)]"
        SayError $errMessage
        return $null
    }
}