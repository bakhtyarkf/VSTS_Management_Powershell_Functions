function Get-TeamMembers
{
    [CmdletBinding()]
    Param(
        # Already set Variables
        $ProjectName
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
        $ProjId = (Get-Projects | Where-Object {$_.name -eq $ProjectName}).id
        $Teams = Get-ProjectTeams -ProjectId $ProjId

        foreach ($Team in $Teams) {
            $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/_apis/projects/" + 
                    $ProjId + "/teams/" + $Team.id + "/members?api-version=1.0"
            $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                            -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
            Write-Output $vstsResult.value
        }
        
    }
    End
    {
    }
}



