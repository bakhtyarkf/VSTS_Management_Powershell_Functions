<#
.Synopsis
   Outputs the Projects of a certain User
#>
function Get-UserVstsInfo
{
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True)]
        [Object]$UserEmail
    )

    Begin
    {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName,$vstsToken)))

        . ".\Get-UserId.ps1"
    }
    Process
    {   
        $id = Get-UserId -Email $UserEmail
        $VstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements/" + $id + "?api-version=4.1-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.projectEntitlements
    }
    End
    {
    }
}