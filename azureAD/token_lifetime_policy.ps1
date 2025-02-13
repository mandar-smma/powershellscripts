# to specify the lifetime of an access, SAML, or ID token issued by the Microsoft identity platform
# for an app ID (registered in Entra platform)
Install-Module Microsoft.Graph

Connect-MgGraph -Scopes  "Policy.ReadWrite.ApplicationConfiguration","Policy.Read.All","Application.ReadWrite.All"

# Create a token lifetime policy
$params = @{
  Definition = @('{"TokenLifetimePolicy":{"Version":1,"AccessTokenLifetime":"8:00:00"}}') # specify lifetime value
    DisplayName = "WebPolicyScenario"
  IsOrganizationDefault = $false
}
$tokenLifetimePolicyId=(New-MgPolicyTokenLifetimePolicy -BodyParameter $params).Id

# Display the policy
Get-MgPolicyTokenLifetimePolicy -TokenLifetimePolicyId $tokenLifetimePolicyId

# Assign the token lifetime policy to an app
$params = @{
  "@odata.id" = "https://graph.microsoft.com/v1.0/policies/tokenLifetimePolicies/$tokenLifetimePolicyId"
}

$applicationObjectId="aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb" # use your app ID

New-MgApplicationTokenLifetimePolicyByRef -ApplicationId $applicationObjectId -BodyParameter $params

# List the token lifetime policy on the app
Get-MgApplicationTokenLifetimePolicy -ApplicationId $applicationObjectId

# Remove the policy from the app
#Remove-MgApplicationTokenLifetimePolicyByRef -ApplicationId $applicationObjectId -TokenLifetimePolicyId $tokenLifetimePolicyId

# Delete the policy
#Remove-MgPolicyTokenLifetimePolicy -TokenLifetimePolicyId $tokenLifetimePolicyId