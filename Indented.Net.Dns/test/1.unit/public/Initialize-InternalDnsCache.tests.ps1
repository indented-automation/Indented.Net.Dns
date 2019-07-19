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
    Describe Initialize-InternalDnsCacheRecord {
        Context 'Mocked' {
            BeforeAll {
                Mock Get-Content {
                    '.                        3600000      NS    A.ROOT-SERVERS.NET.'
                    'A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4'
                    'A.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:ba3e::2:30'
                }
                Mock Add-InternalDnsCacheRecord
            }

            AfterAll {
                Initialize-InternalDnsCache
            }

            It 'Imports named.root into the cache' {
                Initialize-InternalDnsCache

                Assert-MockCalled Get-Content
                Assert-MockCalled Add-InternalDnsCacheRecord
            }
        }
    }
}