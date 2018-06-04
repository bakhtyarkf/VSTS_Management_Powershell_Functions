function New-AzVstsList {

    Param(
        $AzList = ".\azUsersInfo.csv",
        $VstsList = ".\vstsUsersInfo.csv"
    )
    Import-Module PSExcel
    $az = Import-Csv -Path $AzList -Delimiter "|"
    $vsts = Import-Csv -Path $VstsList -Delimiter "|"

    $list =
        $vsts |
            ForEach-Object {
                $vstsuser = $_
                $azuser = $az | Where-Object {$_.mail -eq $vstsuser.mail -or $_.UPN -eq $vstsuser.mail}
                $lic = if ($vstsuser.vstsLicenseType -eq "none") { $vstsuser.msdnLicenseType } else { $vstsuser.vstsLicenseType }
                $props =  @{
                    "Name"= $vstsuser.name; 
                    "Mail"= $vstsuser.mail; 
                    "License Type"= $lic
                    "Department"= $azuser.Department;
                }
                $currUser = New-Object -TypeName psobject -Property $props
                return $currUser
            }
    $list | Export-XLSX -Path .\list.xlsx -Force -AutoFit
}
