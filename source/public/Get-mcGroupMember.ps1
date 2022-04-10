#https://integrations.Mimecast.com/documentation/endpoint-reference/directory/get-group-members/
Function Get-mcGroupMember {
    [cmdletbinding(DefaultParameterSetName = 'byGroupID')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'byGroupID')]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $GroupID,

        [Parameter(Mandatory, ParameterSetName = 'byGroupObject')]
        [ValidateNotNullOrEmpty()]
        $GroupObject,

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
        [int]
        $PageSize = 500
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

    if ($PageSize -notin 1..500) {
        SayWarning "The PageSize value of $($PageSize) is not within the valid range. Try again and enter a value from 1 to 500 only."
        return $null
    }

    if ($pscmdlet.ParameterSetName -eq 'byGroupID') {
        $isGroupID = $true
        $inputObject = $GroupID
    }
    if ($pscmdlet.ParameterSetName -eq 'byGroupObject') {
        $isGroupID = $false
        $inputObject = $GroupObject
    }

    #Setup required variables
    $baseUrl = "https://$Region-api.Mimecast.com"
    if ($Region -eq 'offshore') {
        $baseUrl = "https://je-api.Mimecast.com"
    }
    $uri = "/api/directory/get-group-members"
    $url = $baseUrl + $uri
    $requestId = [guid]::NewGuid().guid

    $finalResult = [System.Collections.ArrayList]@()

    $inputObject | ForEach-Object {
        # If input is group ID, lookup the group first
        if ($isGroupID) {
            if (!($groupObj = Get-mcGroupById -GroupID $_ @keySplat)) {
                SayWarning "Cannot find the group with ID [$($_)]. Skipping."
                continue
            }
        }
        else {
            $groupObj = $_
        }

        if ($groupObj.userCount -lt 1) {
            SayInfo "[$($groupObj.description)] has zero members. Skipping."
        }
        else {
            # Get authorization header, request ID is consistent
            $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri
            # Create post body
            $postBody = @{
                meta = @{
                    pagination = @{
                        pageSize  = $PageSize
                        pageToken = ""
                    }
                }
                data = @(
                    @{
                        id = $($groupObj.id)
                    }
                )
            }

            Say '======================================================================'
            SayInfo "Group Name - [$($groupObj.description)]"
            SayInfo "Group Id - [$($groupObj.id)]"

            $props = [ordered]@{
                groupName         = $($groupObj.description)
                groupID           = $($groupObj.id)
                groupMembers      = [System.Collections.ArrayList]@()
                totalMembersCount = 0
            }
            $tempObj = New-Object psobject -Property $props

            #Send Request
            try {
                $pageStartTime = $(Get-Date)
                $response = @(Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json)" -Uri $url -ErrorAction STOP)
                $pageElapsed = $(Get-Date) - $pageStartTime
                $totalCount = [int]($response.meta.pagination.totalCount)
                $i = @($response.data.groupmembers).Count
                SayInfo "Retrieved [$(@($response.data.groupmembers).Count)] members in $('{0:N2}' -f $pageElapsed.TotalSeconds) seconds [Progress: $i of $totalCount]"
                if ($totalCount -gt 0) {
                    $tempObj.groupMembers.AddRange(@($response.data.groupmembers))
                    $tempObj.totalMembersCount = $totalCount
                    while ($response.meta.pagination.next) {
                        $postBody.meta.pagination['pageToken'] = $($response.meta.pagination.next)
                        $headers = New-mcAuthHeader @keySplat -requestID $requestId -uri $uri
                        $pageStartTime = $(Get-Date)
                        $response = @(Invoke-RestMethod -Method Post -Headers $Headers -Body "$($postBody | ConvertTo-Json)" -Uri $url -ErrorAction STOP)
                        $pageElapsed = $(Get-Date) - $pageStartTime
                        $i = $i + @($response.data.groupmembers).Count
                        SayInfo "Retrieved [$(@($response.data.groupmembers).Count)] members in $('{0:N2}' -f $pageElapsed.TotalSeconds) seconds [Progress: $i of $totalCount]"
                        $tempObj.groupMembers.AddRange($response.data.groupmembers)
                    }
                    $null = $finalResult.Add($tempObj)
                }
            }
            catch {
                SayError $_
            }
        }
    }

    Say '======================================================================'
    $totalTime = ($(Get-Date) - $startTime)
    SayInfo "End"
    Say "Total duration - $($totalTime)"
    return $finalResult
}