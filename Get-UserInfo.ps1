function Get-UserInfo
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        $userEmail
    )

    Begin
    {
        . ".\Get-AzureUsersData.ps1"
        . ".\Get-VstsUsersData.ps1"
    }
    Process
    {
        $userVstsData = Get-VstsUsersData | Where-Object { $_.mail -eq $userEmail}
        $userAzureData = Get-AzureUsersData | Where-Object { $_.mail -eq $userEmail}

        $userInfo = @{
            userVstsData = $userVstsData
            userAzureData = $userAzureData
        }
        Write-Output $userInfo
    }
    End
    {
    }
}