#https://integrations.Mimecast.com/documentation/endpoint-reference/directory/find-groups/
Function Get-mcGroup {
    [cmdletbinding()]
    param(
        [Parameter()]
        [String]
        $Group,

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
        [int]
        $TopResult
    )

    # Create the API keys splat
    $keySplat = @{
        accessKey = $accessKey
        secretKey = $secretKey
        appId     = $appId
        appKey    = $appKey
    }

    SayInfo "Start"
    $startTime = $(Get-Date)

    if ($TopResult) {
        SayInfo "Maximum result = $($TopResult)"
    }
    else {
        SayInfo "Maximum result = Unlimited"
    }

    #Setup required variables
    $baseUrl = "https://$Region-api.Mimecast.com"
    if ($Region -eq 'offshore') {
        $baseUrl = "https://je-api.Mimecast.com"
    }
    $uri = "/api/directory/find-groups"
    $url = $baseUrl + $uri

    $requestId = [guid]::NewGuid().guid
    $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri

    # Create post body
    $postBody = @{
        meta = @{
            pagination = @{
                pageSize  = 10
                pageToken = ""
            }
        }
        data = @(
            @{
                source = "cloud"
            }
        )
    }

    if ($TopResult) {
        $postBody.meta.pagination.pageSize = $TopResult
    }

    # Add @{query = "group name"} to the request if $Group is specified
    if ($Group) {
        $postBody.data[0].Add('query', $Group)
    }

    $finalResult = [System.Collections.ArrayList]@()

    #Send Request
    try {
        $pageStartTime = $(Get-Date)
        $response = @(Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json)" -Uri $url -ErrorAction STOP)
        $pageElapsed = $(Get-Date) - $pageStartTime
        $totalCount = [int]($response.meta.pagination.totalCount)
        $i = ($response.data.folders).Count
        SayInfo "Retrieved [$(@($response.data.folders).Count)] groups in $('{0:N2}' -f $pageElapsed.TotalSeconds) seconds [Progress: $i of $totalCount]"

        $finalResult.AddRange(@($response.data.folders))
        if (!$TopResult) {
            while ($response.meta.pagination.next) {
                $postBody.meta.pagination['pageToken'] = $($response.meta.pagination.next)
                $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri
                $pageStartTime = $(Get-Date)
                $response = @(Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json)" -Uri $url -ErrorAction STOP)
                $pageElapsed = $(Get-Date) - $pageStartTime
                $i = $i + ($response.data.folders).Count
                SayInfo "Retrieved [$(@($response.data.folders).Count)] groups in $('{0:N2}' -f $pageElapsed.TotalSeconds) seconds [Progress: $i of $totalCount]"
                $finalResult.AddRange(@($response.data.folders))
            }
        }

        $finalResult = $finalResult | Sort-Object id | Select-Object -Unique *
        SayInfo "Found $($finalResult.Count) unique group IDs."
        $totalTime = ($(Get-Date) - $startTime)
        SayInfo "End"
        Say "Total duration - $($totalTime)"

        return $finalResult
    }
    catch {
        SayError $_
        $totalTime = ($(Get-Date) - $startTime)
        SayInfo "End"
        Say "Total duration - $($totalTime)"
        return $null
    }
}