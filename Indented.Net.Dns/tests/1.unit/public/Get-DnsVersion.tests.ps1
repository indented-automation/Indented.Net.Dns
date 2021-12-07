InModuleScope Indented.Net.Dns {
    Describe Get-DnsVersion {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }

            Mock Get-Dns
        }

        It 'Calls Get-Dns to execute the query' {
            Get-DnsVersion

            Assert-MockCalled Get-Dns
        }
    }
}
