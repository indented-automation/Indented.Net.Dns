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
    Describe GetDnsSuffixSearchList {
        Context 'Windows' {
            BeforeAll {
                Mock Get-CimInstance {
                    [PSCustomObject]@{
                        DNSDomainSuffixSearchOrder = 'domain1.com', 'domain2.com'
                    }
                }
            }

            It 'When the PowerShell version is 5.1, reads the search list using WMI' {
                GetDnsSuffixSearchList | Should -Be 'domain1.com', 'domain2.com'

                Assert-MockCalled Get-CimInstance -Times 1 -Scope It
            }

            It 'When the powershell platform is Win32NT, reads the search list using WMI' {
                GetDnsSuffixSearchList | Should -Be 'domain1.com', 'domain2.com'

                Assert-MockCalled Get-CimInstance -Times 1 -Scope It
            }
        }

        Context 'Not windows' {
            BeforeAll {
                Mock Test-Path { $true }
                Mock Get-Content {
                    'search domain3.com domain4.com'
                    'nameserver 1.2.3.4'
                    'nameserver 2.3.4.5'
                }

                $shouldRemovePlatform = $false
                if (-not $psversiontable.PSObject.Properties.Item('Platform')) {
                    $shouldRemovePlatform = $true
                    $psversiontable | Add-Member -NotePropertyName Platform -NotePropertyValue 'Win32NT'
                }
                $currentPlatform = $psversiontable.Platform

                $psversiontable.Platform = 'NotWindows'
            }

            AfterAll {
                $psversiontable.Platform = $currentPlatform
                if ($shouldRemovePlatform) {
                    $psversiontable.PSObject.Properties.Remove('Platform')
                }
            }

            It 'When the powershell platform is not Win32NT, and resolve.conf exists, reads the seach list' {
                GetDnsSuffixSearchList | Should -Be 'domain3.com', 'domain4.com'

                Assert-MockCalled Get-Content -Times 1 -Scope It
            }
        }
    }
}