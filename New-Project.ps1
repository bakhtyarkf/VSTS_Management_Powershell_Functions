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
function New-Project
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        $ProjectName,
        $ProjectDesc,
        $VersionControl = "Git",
        $ProcessType = "Agile",
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
	
        $vstsUserUri = " https://$AccName.visualstudio.com/defaultcollection/_apis/projects?api-version=2.0-preview"
        $Processes = @{
            Agile = "adcc42ab-9882-485e-a3ed-7678f01f66bc"
            CMMI = "27450541-8e31-4150-9947-dc59f998fc01"
            Scrum = "6b724908-ef14-45cf-84f8-768b5384da45"
        }
        $vstsUEBody = @{
                            name = $ProjectName
                            description = ""
                            visibility = "private"
                            capabilities = @{ 
                                versioncontrol = @{ sourceControlType = $VersionControl }
                                processTemplate = @{ templateTypeId = $Processes[$ProcessType] }
                            } 
                        }

        $RestParams = @{
            ContentType = "application/json"
            Method = 'Post'
            URI = $vstsUserUri
            Body = $vstsUEBody | ConvertTo-Json
            Headers = @{Authorization=("Basic {0}" -f $VstsAuth)}
        }
        $vstsUpdateResult = Invoke-RestMethod @RestParams

        Write-Output $vstsUpdateResult.id
    }
    End
    {
    }
}