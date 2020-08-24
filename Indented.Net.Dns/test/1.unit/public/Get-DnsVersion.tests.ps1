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
