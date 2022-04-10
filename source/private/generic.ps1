Function SayError {
    param(
        $Text
    )
    $originalForegroundColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = 'Red'
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss (zzz)') : [ERROR] $Text" | Out-Default
    $Host.UI.RawUI.ForegroundColor = $originalForegroundColor
}

Function SayInfo {
    param(
        $Text
    )
    $originalForegroundColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = 'Green'
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss (zzz)') : [INFO] $Text" | Out-Default
    $Host.UI.RawUI.ForegroundColor = $originalForegroundColor
}

Function SayWarning {
    param(
        $Text
    )
    $originalForegroundColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = 'Yellow'
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss (zzz)') : [WARNING] $Text" | Out-Default
    $Host.UI.RawUI.ForegroundColor = $originalForegroundColor
}

Function Say {
    param(
        $Text
    )
    $originalForegroundColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    $Text | Out-Default
    $Host.UI.RawUI.ForegroundColor = $originalForegroundColor
}

Function LogEnd {
    $txnLog = ""
    Do {
        try {
            Stop-Transcript | Out-Null
        }
        catch [System.InvalidOperationException] {
            $txnLog = "stopped"
        }
    } While ($txnLog -ne "stopped")
}

Function LogStart {
    param (
        [Parameter(Mandatory = $true)]
        [string]$logPath
    )
    LogEnd
    Start-Transcript $logPath -Force | Out-Null
}

Function isWindows {
    param()
    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        return $true
    }
    else {
        return $false
    }
}

Function decodeSecureString {
    param (
        [Parameter(Mandatory)]
        [SecureString]
        $SecureString
    )
    return $(
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            $([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
            )
        )
    )
}

Function Get-ThisModule {
    return $MyInvocation.MyCommand.Module
}