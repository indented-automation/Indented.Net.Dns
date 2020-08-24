InModuleScope Indented.Net.Dns {
    Describe Get-DnsServerList {
        It 'Attempts to get a list of DNS servers which can be used' {
            Get-DnsServerList | Should -Not -BeNullOrEmpty
        }
    }
}
