Import-Module PSExcel

function Get-Projects
{
    [CmdletBinding()]
    Param(
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
        $VstsUri = "https://$AccName.visualstudio.com/_apis/projects?top=10000&api-version=4.1-preview.1"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.value
    }
    End
    {
    }
}

function Get-ProjectTeams
{

    [CmdletBinding()]
    Param(
        $ProjectInfo
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
        $VstsUri = "https://$AccName.visualstudio.com/_apis/projects/" + $ProjectInfo.id + 
                    "/teams?api-version=4.1"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.value
    }
    End
    {
    }
}


function Get-TeamMembers
{
    [CmdletBinding()]
    Param(
        # Already set Variables
        $ProjectId,
        $TeamId
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
        $VstsUri = "https://$AccName.visualstudio.com/_apis/projects/" + 
                            $ProjectId + "/teams/" + $TeamId + "/members?api-version=4.1"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult.value

    }
    End
    {
    }
}


function Get-UserVstsInfo
{
    [CmdletBinding()]
    Param(
        [Object]$UserVstsId
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
        $VstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements/" + $UserVstsId + 
                    "?api-version=4.1-preview"
        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        Write-Output $vstsResult
    }
    End
    {
    }
}


function Get-AllUsersVstsInfo
{
    [CmdletBinding()]
    Param(
        [Object]$UserVstsId
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
        $VstsUri_AllUsers = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?top=10000&skip=0&api-version=4.1-preview.1"
        $AllUsers = Invoke-RestMethod -Uri $VstsUri_AllUsers -Method Get -ContentType "application/json" `
                                        -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}
        $AllUsers.value |
        ForEach-Object {
            $userInfo = Get-UserVstsInfo -UserVstsId $_.id
            Write-Output $userInfo
        }
    }
    End
    {
    }
}

$alluseres = Get-AllUsersVstsInfo

$AllProjects = Get-Projects 

$AllProjectTeams = $AllProjects | ForEach-Object {
    $Project = $_
    Get-ProjectTeams -ProjectInfo $Project | 
    ForEach-Object {
        $Params = @{
            ProjectId = $Project.id
            ProjectName = $Project.name
            TeamId = $_.id
            TeamName = $_.name
        }
        $res = New-Object -TypeName psobject -Property $Params
        Write-Output $res
    }
}

$PTUs = $AllProjectTeams | ForEach-Object {
    $Info = $_
    Get-TeamMembers -ProjectId $Info.ProjectId -TeamId $Info.TeamId |
    ForEach-Object {
        if ($_.isTeamAdmin) {
            $isAdmin = "Yes" 
        } else {
            $isAdmin = "No"
        }

        $Params = @{
            ProjectId = $Info.ProjectId
            ProjectName = $Info.ProjectName
            TeamId = $Info.TeamId
            TeamName = $Info.TeamName
            isTeamAdmin = $isAdmin
            UserId = $_.identity.id
            UserName = $_.identity.displayName
            UserEmail = $_.identity.uniqueName
        }
        $res = New-Object -TypeName psobject -Property $Params
        Write-Output $res
    }
}   

$AllInfos = $PTUs | ForEach-Object {

    $CurrPTU = $_
    $User = $alluseres | Where-Object { $_.id -eq $CurrPTU.UserId}
    $ProjectEntitlment = $User.projectEntitlements | Where-Object { $_.projectRef.id -eq $CurrPTU.ProjectId }
    $Params = @{
        ProjectId = $CurrPTU.ProjectId
        ProjectName = $CurrPTU.ProjectName
        TeamId = $CurrPTU.TeamId
        TeamName = $CurrPTU.TeamName
        isTeamAdmin = $CurrPTU.isTeamAdmin
        UserId = $CurrPTU.UserId
        UserName = $CurrPTU.UserName
        UserEmail = $CurrPTU.UserEmail
        ProjectAccessLevel = $ProjectEntitlment.group.displayName
    }
    $res = New-Object -TypeName psobject -Property $Params
    Write-Output $res
}

$AllInfos |
Where-Object { $_.ProjectAccessLevel} |
Select-Object ProjectName, TeamName, isTeamAdmin, UserName, UserEmail, ProjectAccessLevel |
Export-XLSX -AutoFit -Path ".\VstsInfo.xlsx" -Force