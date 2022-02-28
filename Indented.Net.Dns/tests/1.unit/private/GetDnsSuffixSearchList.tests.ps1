Describe GetDnsSuffixSearchList {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    Context 'Windows' {
        BeforeAll {
            Mock Get-CimInstance @module {
                [PSCustomObject]@{
                    DNSDomainSuffixSearchOrder = 'domain1.com', 'domain2.com'
                }
            }
        }

        It 'When the PowerShell version is 5.1, reads the search list using WMI' {
            InModuleScope @module { GetDnsSuffixSearchList } | Should -Be 'domain1.com', 'domain2.com'

            Should -Invoke Get-CimInstance @module
        }

        It 'When the powershell platform is Win32NT, reads the search list using WMI' {
            InModuleScope @module { GetDnsSuffixSearchList } | Should -Be 'domain1.com', 'domain2.com'

            Should -Invoke Get-CimInstance @module
        }
    }

    Context 'Not windows' {
        BeforeAll {
            Mock Test-Path @module {
                $true
            }
            Mock Get-Content @module {
                'search domain3.com domain4.com'
                'nameserver 1.2.3.4'
                'nameserver 2.3.4.5'
            }

            $shouldRemovePlatform = $false
            if (-not $PSVersionTable.PSObject.Properties.Item('Platform')) {
                $shouldRemovePlatform = $true
                $PSVersionTable | Add-Member -NotePropertyName Platform -NotePropertyValue 'Win32NT'
            }
            $currentPlatform = $PSVersionTable.Platform

            $PSVersionTable.Platform = 'NotWindows'
        }

        AfterAll {
            $PSVersionTable.Platform = $currentPlatform
            if ($shouldRemovePlatform) {
                $PSVersionTable.PSObject.Properties.Remove('Platform')
            }
        }

        It 'When the powershell platform is not Win32NT, and resolve.conf exists, reads the seach list' {
            InModuleScope @module { GetDnsSuffixSearchList } | Should -Be 'domain3.com', 'domain4.com'

            Should -Invoke Get-Content @module
        }
    }
}
