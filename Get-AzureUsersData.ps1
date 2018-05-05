<#
.Synopsis
   generate Azure and Vsts Information CSV Files
.EXAMPLE
   Get-InfoToCSV
#>
function Get-AzureUsersData
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
        if ( Test-Path "./pass.txt") {
            $azPass = Get-Content "./pass.txt" | ConvertTo-SecureString
        } else {
            ConvertFrom-SecureString $(Get-Credential).Password | Out-File pass.txt
            $azPass = Get-Content "./pass.txt" | ConvertTo-SecureString
        }
        $creds = New-Object System.Management.Automation.PSCredential ($userName, $azPass)
    }
    Process
    {
        Connect-AzureAD -Credential $creds | Out-Null
        $userInfo = Get-AzureADUser -All:$true
        $ADUsersInfo = $userInfo | Select-Object -Property *
        $ADOptInfo = $ADUsersInfo | ForEach-Object {
            if ($_.DisplayName -notmatch '\w\d+') {
                $currUser = New-Object -TypeName psobject -Property @{
                    "Mail"=$_.Mail;
                    "AccountEnabled"=$_.AccountEnabled;
                    "Department"=$_.Department;
                    "ObjectId"=$_.ObjectId; 
                }
                return $currUser
            }
        }

        Write-Output $ADOptInfo
    }
    End
    {
    }
}

# Export-ModuleMember -Function Get-AzureUsersData