function Grant-License {
    [OutputType([int])]
    Param
    (
        $userEmail,
		$LicenseType
    )

    Begin {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $vstsToken)))
    }
    Process {

        $vstsUserUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements?api-version=4.1-preview"
        # $vstsUEBody = @{
        #     accessLevel = @{ accountLicenseType = "express" }
        #     user = @{ principalName = $userEmail; subjectKind = "user" }
        #     projectEntitlements = @{ 
        #         group = @{ groupType = $projAccessLevel }
        #         projectRef = @{ id = $projId }
        #     } 
        # }

        $vstsUEBody = @'
{
	"accessLevel": {
		"accountLicenseType": "
'@ + $LicenseType + @'
"
	},
	"user": {
	"principalName": "
'@ + $userEmail + @'         
",
	"subjectKind": "user"
	}
}     
'@
        Write-Output $vstsUEBody

        $RestParams = @{
            ContentType = "application/json"
            Method = 'Post'
            URI = $vstsUserUri
            Body = $vstsUEBody
            Headers = @{Authorization=("Basic {0}" -f $VstsAuth)}
        }

        Invoke-RestMethod @RestParams
	
    }
    End {
    }
}