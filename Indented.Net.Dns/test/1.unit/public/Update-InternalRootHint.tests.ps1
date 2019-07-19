#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

InModuleScope Indented.Net.Dns {
    Describe Update-InternalRootHint {
        BeforeAll {
            Mock Invoke-WebRequest
            Mock Initialize-InternalDnsCache
        }

        It 'Downloads and updates named.root from internic' {
            Update-InternalRootHint

            Assert-MockCalled Invoke-WebRequest
            Assert-MockCalled Initialize-InternalDnsCache
        }
    }
}