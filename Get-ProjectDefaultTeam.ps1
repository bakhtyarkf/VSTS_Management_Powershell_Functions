function Get-ProjectDefaultTeam
{
    [CmdletBinding()]
    Param(
        [string]$ProjName
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
    {   
        $ProjId = (Get-Projects | Where-Object {$_.name -eq $ProjName}).id
        $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/_apis/projects/" + $ProjId + "?api-version=1.0"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.defaultTeam
    }
    End
    {
    }
}