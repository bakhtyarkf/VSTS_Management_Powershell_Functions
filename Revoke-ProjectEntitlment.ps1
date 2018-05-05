function Revoke-ProjectEntitlment {
    [OutputType([int])]
    Param
    (
        $userId,
		$ProjectId
    )

    Begin {
        $creds = Import-Clixml -Path creds.xml
        [string]$AccName = $creds.AccountName
        [string]$userName = $creds.UserName
        [string]$vstsToken = $creds.Token
        $VstsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $userName, $vstsToken)))
    }
    Process {

        $vstsUserUri = "https://$AccName.vsaex.visualstudio.com/_apis/userentitlements/" + $userId + "?api-version=4.1-preview"
        # $vstsUEBody = @{
        #     accessLevel = @{ accountLicenseType = "express" }
        #     user = @{ principalName = $userEmail; subjectKind = "user" }
        #     projectEntitlements = @{ 
        #         group = @{ groupType = $projAccessLevel }
        #         projectRef = @{ id = $projId }
        #     } 
        # }

        $vstsUEBody = @'
        [
            {
            "from": "",
            "op": "remove",
            "path": "/projectEntitlements/
'@ + $ProjectId + @'
",
            "value": ""
            }
        ]
'@
        Write-Output $vstsUEBody

        $RestParams = @{
            ContentType = "application/json-patch+json"
            Method = 'PATCH'
            URI = $vstsUserUri
            Body = $vstsUEBody
            Headers = @{Authorization=("Basic {0}" -f $VstsAuth)}
        }

        Invoke-RestMethod @RestParams
	
    }
    End {
    }
}


Revoke-ProjectEntitlment -userId $userId -ProjectId $ProjectId