function Get-UserId
{
    [CmdletBinding()]
    Param(
        [Object]$Email
    )

    Begin
    {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName,$vstsToken)))    
    }
    Process
    {   $VstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?top=10000&api-version=4.1-preview.1"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        $id = ($vstsResult.value | Where-Object { $_.user.mailAddress.ToLower() -eq $Email.ToLower() }).id
        Write-Output $id
    }
    End
    {
    }
}