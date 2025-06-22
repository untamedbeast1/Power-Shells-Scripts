#Audits and reports on the membership of highly privileged administrative roles in Azure Active Directory.

#DESCRIPTION:This script identifies key administrative roles (e.g., Global Administrator, Security Administrator) and lists the users assigned to them.
#It helps in regularly reviewing who has powerful permissions within the Azure AD tenant, which is a key security practice.

#EXAMPLE
#.\Get-AzureAD_PrivilegedRoleMembers.ps1
#Connects to Azure AD and exports a list of privileged role members to C:\temp\AzureAD_PrivilegedRoles_Report.csv.

#Requires -Module AzureAD

# Define the privileged roles you want to audit.
$privilegedRoles = @(
    "Global Administrator",
    "Security Administrator",
    "SharePoint Administrator",
    "Exchange Administrator",
    "User Administrator"
)

try {
    # Connect to Azure AD.
    Write-Host "Connecting to Azure Active Directory..."
    Connect-AzureAD
    Write-Host "Connection successful."
}
catch {
    Write-Error "Failed to connect to AzureAD. Please ensure the module is installed and you have appropriate permissions."
    return
}


$allRoleMembers = @()

foreach ($roleName in $privilegedRoles) {
    Write-Host "Checking for members in role: $roleName"
    try {
        $role = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq $roleName }

        if ($null -ne $role) {
            $members = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
            if ($null -ne $members) {
                foreach ($member in $members) {
                    $allRoleMembers += [PSCustomObject]@{
                        RoleName          = $roleName
                        MemberDisplayName = $member.DisplayName
                        UserPrincipalName = $member.UserPrincipalName
                        ObjectType        = $member.ObjectType
                    }
                }
            }
        } else {
            Write-Warning "Role '$roleName' not found."
        }
    }
    catch {
        Write-Warning "Could not retrieve members for role '$roleName'. Error: $($_.Exception.Message)"
    }
}

# Export the results to a CSV file.
if ($allRoleMembers.Count -gt 0) {
    $exportPath = "C:\temp\AzureAD_PrivilegedRoles_Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
    Write-Host "Exporting $($allRoleMembers.Count) privileged role assignments to $exportPath"
    $allRoleMembers | Export-Csv -Path $exportPath -NoTypeInformation
} else {
    Write-Host "No members found in the specified privileged roles."
}

Write-Host "Script finished."
