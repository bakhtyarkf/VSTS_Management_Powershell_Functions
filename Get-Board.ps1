function Get-Board
{
    [CmdletBinding()]
    Param(
        $projectName,
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
        $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/$projectName/$projectName%20Team/_apis/work/boards/Stories/columns?api-version=2.0-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.value
    }
    End
    {
    }
}
