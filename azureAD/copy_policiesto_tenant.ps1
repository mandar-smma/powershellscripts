#Copying Conditional Access policies from one Azure AD tenant to another via PowerShell
# Connect to source tenant
Connect-MgGraph -TenantId "<source-tenant-id>" #example production tenant

# Export policies from source tenant
$policies = Get-MgConditionalAccessPolicy
# OR Get all the Permission Grant Policies
# $policies = Get-MgDirectoryRoleDefinition

$policies | ConvertTo-Json | Out-File -FilePath "Policies.json"

# Connect to target tenant
Connect-MgGraph -TenantId "<target-tenant-id>" #example test tenant

# Import and recreate policies in target tenant
$importedPolicies = Get-Content -Path "Policies.json" | ConvertFrom-Json
foreach ($policy in $importedPolicies) {
    # Use the policy details to create new policies in the target tenant
    New-MgConditionalAccessPolicy -DisplayName $policy.DisplayName -State $policy.State -Conditions $policy.Conditions -GrantControls $policy.GrantControls
    # New-MgDirectoryRoleDefinition -DisplayName $policy.DisplayName -Description $policy.Description
}