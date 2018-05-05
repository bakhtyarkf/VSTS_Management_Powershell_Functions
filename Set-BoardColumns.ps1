function Set-BoardColumns
{
    [CmdletBinding()]
    Param(
        $projectName
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
        $Body = Get-Board -projectName $projectName

        $Body[0].name = "Funnel"
        $Body[1].name = "Reviewing"
        $Body = $Body | ConvertTo-Json

        $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/$projectName/$projectName%20Team/_apis/work/boards/Stories/columns?api-version=2.0-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Put -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)} -Body $Body
        Write-Output $vstsResult.value
    }
    End
    {
    }
}

function Get-Board
{
    [CmdletBinding()]
    Param(
        $projectName,
        $boardname
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
        $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/$projectName/$projectName%20Team/_apis/work/boards/$boardname/columns?api-version=2.0-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.value
    }
    End
    {
    }
}



function Set-BoardColumns
{
    [CmdletBinding()]
    Param(
        $projectName,
        $boardname
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
        $Body = Get-Board -projectName $projectName -boardname $boardname

        $funnelCol = $Body | Where-Object {$_.name -eq "Funnel"}
        $ReviewingCol = $Body | Where-Object {$_.name -eq "Reviewing"}

        if (-not $funnelCol) {
            $Body[0].name = "Funnel"
        }

        if (-not $ReviewingCol) {
            $Body[1].name = "Reviewing"
        }
        
        


        $Body = $Body | ConvertTo-Json

        $VstsUri = "https://$AccName.visualstudio.com/DefaultCollection/$projectName/$projectName%20Team/_apis/work/boards/$boardname/columns?api-version=2.0-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Put -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)} -Body $Body
        Write-Output $vstsResult.value
    }
    End
    {
    }
}

