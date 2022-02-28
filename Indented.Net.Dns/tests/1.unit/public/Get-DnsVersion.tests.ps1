Describe Get-DnsVersion {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Mock Get-Dns @module
    }

    It 'Calls Get-Dns to execute the query' {
        Get-DnsVersion

        Should -Invoke Get-Dns @module
    }
}
