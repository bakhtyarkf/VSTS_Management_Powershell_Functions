<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Revoke-License
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Object]$vstsId
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
	
	$vstsUserUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements/" + `
							$vstsId + "?api-version=4.1-preview"


	$vstsUpdateResult = Invoke-RestMethod -Uri $vstsUserUri -Method Delete -ContentType "application/json" `
									-Headers @{Authorization=("Basic {0}" -f $VstsAuth)} -Body $vstsUEBody
	
    Write-Output $vstsUpdateResult.isSuccess

    }
    End
    {
    }
}
