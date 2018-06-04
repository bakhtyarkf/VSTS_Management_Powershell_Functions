<#
.Synopsis
   generate Azure and Vsts Information CSV Files
.EXAMPLE
   Get-InfoToCSV
#>
function Get-InfoToCSV
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
    )

    Begin
    {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $Password = $creds.Password | ConvertTo-SecureString
        $vstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?top=500&skip=0&api-version=4.1-preview"

        $creds = New-Object System.Management.Automation.PSCredential ($userName, $Password)
        $vstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName,$vstsToken)))
    }
    Process
    {
        
        
        

        $vstsResult = Invoke-RestMethod -Uri $vstsUri -Method Get -ContentType "application/json" `
                    -Headers @{Authorization=("Basic {0}" -f $vstsAuth)}


        $vstsInfo = $vstsResult.value | Select-Object -Property *

        Connect-AzureAD -Credential $creds | Out-Null
        $userInfo = Get-AzureADUser -All:$true
        $ADUsersInfo = $userInfo | Select-Object -Property * 

        $azUsersInfo =
            $ADUsersInfo |
                ForEach-Object {
                    if ($_.DisplayName -notmatch '\w\d+') {
                        $props =  @{
                            "AzId"=$_.ObjectId; 
                            "name"=$_.DisplayName; 
                            "mail"= $_.mail;
                            "UPN"= $_.UserPrincipalName;
                            "Department"=$_.department;
                        }
                        $currUser = New-Object -TypeName psobject -Property $props
                        return $currUser
                    }     
                }



        $vstsOptInfo = 
            $vstsInfo  |
                ForEach-Object {
                    if ($_.DisplayName -notmatch '\w\d+') {
                        $lastAccessedDate;
                        $tempDate = Get-Date $_.lastAccessedDate -Format d
                        $lastAccessedDate = if ($tempDate -eq "01-01-0001") { $null } else { Get-Date $tempDate -Format d}
                        $props =  @{
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
                        $currUser = New-Object -TypeName psobject -Property $props
                        return $currUser
                    }
                }

        $vstsIds = 
        $vstsInfo  |
            ForEach-Object {
                if ($_.DisplayName -notmatch '\w\d+') {
                    $props =  @{ "id"=$_.id; "mail"=$_.user.mailAddress; }
                    $currUser = New-Object -TypeName psobject -Property $props
                    return $currUser
                }
            }

        $azUsersInfo | Where-Object { $_.mail -and $_.department } | ConvertTo-Csv -Delimiter "|" -NoTypeInformation |
                        % {$_.Replace('"','')} | Out-File 'azUsersInfo.csv' -Encoding UTF8 -Force


        $vstsOptInfo | Where-Object { $_.mail } | ConvertTo-CSV -Delimiter "|" -NoTypeInformation |
                        % {$_.Replace('"','')} | Out-File 'vstsUsersInfo.csv' -Encoding UTF8 -Force
    }
    End
    {
    }
}
