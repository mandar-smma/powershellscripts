[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AdApplicationName,

    [Parameter()]
    [string]$OutputFilePath

    [Parameter(Mandatory)]
    [string][]$roles,
)

$subscriptionId = (Get-AzSubscription).Id #or $(azureResourceManagerConnectionName) if in AzDo
$vmMngApp = Get-AzADApplication -DisplayName $AdApplicationName #check if app exists in AD
$sp = $null

if ($null -eq $vmMngApp){ # New
    $vmMngApp = New-AzADApplication -DisplayName $AdApplicationName #creates azureAD app
    $sp = New-AzADServicePrincipal -ApplicationId $vmMngApp.AppId # create service principal
}
else{ # Existing
    $sp = Get-AzADServicePrincipal -ApplicationId $adApp.AppId # get existing service principal
    $oldClientSecret = (Get-AzADApplication -DisplayName $AdApplicationName).PasswordCredentials | Sort-Object StartDateTime | select -First 1
    Remove-AzADAppCredential -ApplicationId $adApp.AppId -KeyId $oldClientSecret.KeyId #remove old secret for existing sp
}

$clientSecret = New-AzADAppCredential -ObjectId $vmMngApp.Id #creates new secret for azureAD app
$clientSecret.SecretText | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File -FilePath $OutputFilePath # save to pwd file
# ideally add the file to keyVault at this point

#assign roles
Write-Output "Retrieved roles: $roles"
foreach ($role in $roles) {
    if(Get-AzRoleDefinition $role) { #check if given azure role is valid
        New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName $role -Scope "/subscriptions/$subscriptionId"
    }
    else {
       Write-Output "The role $role is not valid" 
    }
}

# test if service principal authenticaion works ?
$pass = (Get-Content -Path 'C:\AzureAppPassword.txt' | ConvertTo-SecureString)
$azureAppCred = New-Object System.Management.Automation.PSCredential($vmMngApp.AppId, $pass)
$subscription = Get-AzSubscription
Connect-AzAccount -ServicePrincipal $sp -SubscriptionId $subscriptionId -TenantId $subscription.TenantId -Credential $azureAppCred
Get-AzVM #chk vm return list in this subscription

