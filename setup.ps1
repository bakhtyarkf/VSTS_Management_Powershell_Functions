Write-Output "Getting Azure Creds"
$creds = Get-Credential
$userName = $creds.UserName
$pass = $creds.Password | ConvertFrom-SecureString


$token = Read-Host -Prompt "Enter the token value"
$AccountName = Read-Host -Prompt "Enter your VSTS account name **https://[your account name].visualstudio.com/**"



$VstsCredsContent = @{
    UserName = $userName
    Password = $pass
    Token = $token
    AccountName = $AccountName
}

$VstsCredsContent | Export-Clixml creds.xml