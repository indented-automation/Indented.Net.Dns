InModuleScope Indented.Net.Dns {
    Describe Get-DnsServerList {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Attempts to get a list of DNS servers which can be used' {
            Get-DnsServerList | Should -Not -BeNullOrEmpty
        }
    }
}
