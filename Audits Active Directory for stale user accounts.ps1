#Audits Active Directory for stale user accounts that have not been logged into for a specified number of days.

#DESCRIPTION: This script queries Active Directory for all enabled user accounts and checks their lastLogonTimestamp attribute.
#If a user has not logged on within the specified timeframe, their information is exported to a CSV file for review.

#PARAMETER DaysInactive
#The maximum number of days a user can be inactive before being flagged as stale. Default is 90 days.

#EXAMPLE
#\Get-StaleADUsers.ps1 -DaysInactive 90

param (
    [int]$DaysInactive = 90
)

#Requires -Module ActiveDirectory

$thresholdDate = (Get-Date).AddDays(-$DaysInactive)

$userProperties = @(
    'Name',
    'SamAccountName',
    'LastLogonDate',
    'DistinguishedName',
    'Enabled'
)

Write-Host "Searching for user accounts inactive for more than $DaysInactive days..."

try {
    $allUsers = Get-ADUser -Filter { Enabled -eq $true } -Properties $userProperties

    $staleUsers = $allUsers | Where-Object {
        ($_.LastLogonDate -lt $thresholdDate) -or ($_.LastLogonDate -eq $null)
    }

    if ($staleUsers.Count -gt 0) {
        $exportPath = "C:\temp\StaleUsers-$(Get-Date -Format 'yyyy-MM-dd').csv"
        Write-Host "Found $($staleUsers.Count) stale user accounts. Exporting list to $exportPath"
        $staleUsers | Select-Object $userProperties | Export-Csv -Path $exportPath -NoTypeInformation
    } else {
        Write-Host "No stale user accounts found for the specified period."
    }
}
catch {
    Write-Error "An error occurred. Please ensure the Active Directory module is installed and you have the necessary permissions."
    Write-Error $_.Exception.Message
}
