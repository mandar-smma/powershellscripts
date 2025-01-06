param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArmOutputString,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [switch]$MakeOutput
)

if($null eq $ArmOutputString) { #insert test json
    $ArmOutputString = @'
        {
            "sqlServerName": {
	        "value" : "[some sql server name].database.windows.net",
            "type": "string"},
            "databaseName": {
		    "value" : "[some sql db name]",
            "type": "string"}
        }
'@
}

Write-Output "Retrieved input: $ArmOutputString"
$armOutputObj = $ArmOutputString | ConvertFrom-Json

$armOutputObj.PSObject.Properties | ForEach-Object {
    $type = ($_.value.type).ToLower()
    $keyname = $_.Name
    $vsoAttribs = @("task.setvariable variable=$keyName")

    if ($type -eq "array") {
        $value = $_.Value.value.name -join ',' ## All array variables will come out as comma-separated strings
    } elseif ($type -eq "securestring") {
        $vsoAttribs += 'isSecret=true'
    } elseif ($type -ne "string") {
        throw "Type '$type' is not supported for '$keyname'"
    } else {
        $value = $_.Value.value
    }
        
    if ($MakeOutput.IsPresent) {
        $vsoAttribs += 'isOutput=true'
    }

    $attribString = $vsoAttribs -join ';'
    $var = "##vso[$attribString]$value"
    Write-Output -InputObject $var
}