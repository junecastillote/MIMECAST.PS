Function New-mcAuthHeader {
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

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $uri,

        [Parameter()]
        [String]
        $requestId
    )

    $plain_accessKey = $(decodeSecureString $accessKey)
    $plain_secretKey = $(decodeSecureString $secretKey)
    $plain_appId = $(decodeSecureString $appId)
    $plain_appKey = $(decodeSecureString $appKey)



    # Region Header
    #Generate request header values
    $hdrDate = (Get-Date).ToUniversalTime().ToString("ddd, dd MMM yyyy HH:mm:ss UTC")
    # $requestId = [guid]::NewGuid().guid
    if (!$requestId) { $requestId = [guid]::NewGuid().guid }

    #Create the HMAC SHA1 of the Base64 decoded secret key for the Authorization header
    $sha = New-Object System.Security.Cryptography.HMACSHA1
    $sha.key = [Convert]::FromBase64String($plain_secretKey)
    $sig = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($hdrDate + ":" + $requestId + ":" + $uri + ":" + $plain_appKey))
    $sig = [Convert]::ToBase64String($sig)

    #Create Headers
    $headers = @{"Authorization" = "MC " + $plain_accessKey + ":" + $sig;
        "x-mc-date"              = $hdrDate;
        "x-mc-app-id"            = $plain_appId;
        "x-mc-req-id"            = $requestId;
        "Content-Type"           = "application/json"
    }
    #EndRegion Header
    $headers
}