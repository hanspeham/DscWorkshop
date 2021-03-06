$here = $PSScriptRoot

$datumDefinitionFile = Join-Path $here ..\..\DSC_ConfigData\Datum.yml
$nodeDefinitions = Get-ChildItem $here\..\..\DSC_ConfigData\AllNodes -Recurse -Include *.yml
$environments = (Get-ChildItem $here\..\..\DSC_ConfigData\AllNodes -Directory).BaseName
$roleDefinitions = Get-ChildItem $here\..\..\DSC_ConfigData\Roles -Recurse -Include *.yml
$datum = New-DatumStructure -DefinitionFile $datumDefinitionFile
$configurationData = Get-FilteredConfigurationData -Environment $environment -Datum $datum -Filter $filter

$nodeNames = [System.Collections.ArrayList]::new()

Describe 'Datum Tree Definition' {
    It 'Exists in DSC_ConfigData Folder' {
        Test-Path $datumDefinitionFile | Should -Be $true
    }

    $datumYamlContent = Get-Content $datumDefinitionFile -Raw
    It 'is Valid Yaml' {
        { $datumYamlContent | ConvertFrom-Yaml } | Should -Not -Throw
    }

}

Describe 'Node Definition Files' {
    $nodeDefinitions.ForEach{
        # A Node cannot be empty
        $content = Get-Content -Path $_ -Raw
        
        if($_.BaseName -ne 'AllNodes') {
            It "$($_.FullName) Should not be duplicated" {
                $nodeNames -contains $_.BaseName | Should -Be $false
            }
        }
        
        $null = $nodeNames.Add($_.BaseName)

        It "$($_.Name) has valid yaml" {
            { $object = $content | ConvertFrom-Yaml } | Should -Not -Throw
        }
    }
}


Describe 'Roles Definition Files' {
    $nodes = $configurationData.AllNodes | Where-Object { $_.NodeName -ne '*' -and $_.Environment -eq $environment }
    $nodeRoles = $nodes | ForEach-Object -MemberName Role
    $usedRolesDefinitions = foreach ($nodeRole in $nodeRoles)
    {
        $roleDefinitions.Where({ $_.FullName -like "*$($nodeRole)*" })
    }

    $usedRolesDefinitions = $usedRolesDefinitions | Group-Object -Property FullName | ForEach-Object { $_.Group[0] }
    
    $usedRolesDefinitions.Foreach{
        # A role can be Empty

        $content = Get-Content -Path $_ -Raw
        if($content) {
            It "$($_.FullName) has valid yaml" {
                { $null = $content | ConvertFrom-Yaml } | Should -Not -Throw
            }
        }
    }
}

Describe 'Role Composition' {
    Foreach($environment in $environments) {
        Context "Nodes for environment $environment" {
            
            Foreach ($node in ($configurationData.AllNodes | Where-Object { $_.NodeName -ne '*' -and $_.Environment -eq $environment })) {
                It "$($node.Name) has a valid Configurations Setting (!`$null)" {
                    {Lookup Configurations -Node $node -DatumTree $datum } | Should -Not -Throw
                }
            }
        }
    }
}