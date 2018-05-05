function Get-VstsAccNotification {
    [OutputType([int])]
    Param
    (
        $nums = 5
    )

    Begin {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $vstsToken)))
    }
    Process {

        $vstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlementsummary?api-version=4.1-preview"

        $RestParams = @{
            ContentType = "application/json"
            Method = 'Get'
            URI = $vstsUri
            Headers = @{Authorization=("Basic {0}" -f $VstsAuth)}
        }

        $vstsUpdateResult = Invoke-RestMethod @RestParams
        $remainingLicenses = $vstsUpdateResult.licenses[0].available
        Write-Output $($remainingLicenses -gt $nums)
    }
    End {
    }
}