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
function Add-UserEntitlement {
    [OutputType([int])]
    Param
    (
        [String]$userEmail,
        [String]$projAccessLevel,
        [String]$projId

        
    )

    Begin {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $vstsToken)))
    }
    Process {

        $vstsUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?api-version=4.1-preview"
        $vstsUEBody = @{
            accessLevel = @{ accountLicenseType = "express" }
            user = @{ principalName = $userEmail; subjectKind = "user" }
            projectEntitlements = @{ 
                group = @{ groupType = $projAccessLevel }
                projectRef = @{ id = $projId }
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
	
    }
    End {
    }
}

# Export-ModuleMember -Function Add-UserEntitlement