# Login to the tenant
az login --allow-no-subscriptions

# Get a reference to the workload application
$workloadAppDisplayName = ""

$workloadAppId = $(az ad sp list --display-name $workloadAppDisplayName | ConvertFrom-Json).id 2>nul

Write-Host "$workloadAppDisplayName's objectID is: $workloadAppId"

# Add the workload application to each of the groups in $targetGroups
$targetGroups = @("caf-level3-landingzones-rw", "caf-level4-landingzones-rw", "CG-AZ-MG-Platform-Reader")

foreach ($group in $targetGroups) {
    $existsInGroup = $(az ad group member check --group $group --member-id $workloadAppId | ConvertFrom-Json).value 2>nul
    
    if ($existsInGroup) {
        Write-Host "$workloadAppDisplayName already exists in $group"
        continue
    }

    az ad group member add --group $group --member-id $workloadAppId 2>nul
    Write-Host "$workloadAppDisplayName added to $group"
}
