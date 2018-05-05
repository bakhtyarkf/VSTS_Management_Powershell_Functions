<#
.Synopsis
   generate Azure and Vsts Information CSV Files
.EXAMPLE
   Get-InfoToCSV
#>
function Get-VstsUsersData
{
    Begin
    {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $vstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?top=1000&skip=0&api-version=4.1-preview"
        $vstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName,$vstsToken)))
    }
    Process
    {
        
        
        

        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                    -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}


        $vstsInfo = $vstsResult.value | Select-Object -Property *

        $vstsOptInfo = 
            $vstsInfo  |
                ForEach-Object {
                    if ($_.DisplayName -notmatch '\w\d+') {
                        $tempDate = Get-Date $_.lastAccessedDate -Format d
                        $lastAccessedDate = if ($tempDate -eq "01-01-0001") { $null } else { Get-Date $tempDate -Format d}
                        $currUser = New-Object -TypeName psobject -Property @{
                            "vstsId"=$_.id;
                            "name"=$_.user.displayName;
                            "mail"=$_.user.mailAddress;
                            "licensingSource"=$_.accessLevel.licensingSource; 
                            "vstsLicenseType"=$_.accessLevel.accountLicenseType;
                            "msdnLicenseType"=$_.accessLevel.msdnLicenseType;
                            "vstsLicenseName"=$_.accessLevel.licenseDisplayName;
                            "vstsAccountStatus"=$_.accessLevel.status;
                            "Last_Access"=$lastAccessedDate;
                            "start_Date" = $null
                        }
                        return $currUser
                    }
                }

        Write-Output $vstsOptInfo
    }
    End
    {
    }
}
