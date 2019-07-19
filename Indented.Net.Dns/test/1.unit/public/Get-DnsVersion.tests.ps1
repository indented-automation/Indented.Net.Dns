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
    Describe Get-DnsVersion {
        BeforeAll {
            Mock Get-Dns
        }

        It 'Calls Get-Dns to execute the query' {
            Get-DnsVersion

            Assert-MockCalled Get-Dns
        }
    }
}