@{
    PSDependOptions              = @{
        AddToPath  = $True
        Target     = 'BuildOutput\Modules'
        Parameters = @{}
    }

    InvokeBuild                  = 'latest'
    BuildHelpers                 = 'latest'
    Pester                       = 'latest'
    PSScriptAnalyzer             = 'latest'
    DscBuildHelpers              = 'latest'
    Datum                        = 'latest'
    ProtectedData                = 'latest'
    'powershell-yaml'            = 'latest'
}