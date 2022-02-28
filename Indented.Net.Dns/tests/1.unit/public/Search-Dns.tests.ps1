Describe Search-Dns {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Mock Get-Dns -ParameterFilter { $RecordType -eq 'NS' } @module {
            [PSCustomObject]@{
                Answer = @(
                    [PSCustomObject]@{
                        Hostname = 'ns1.domain.com.'
                    }
                    [PSCustomObject]@{
                        Hostname = 'ns2.domain.com.'
                    }
                )
            }
        }
        Mock Get-Dns -ParameterFilter { $RecordType -ne 'NS' } @module

        $defaultParams = @{
            Name       = 'www.domain.com.'
            ZoneName   = 'domain.com.'
            RecordType = 'A'
        }
    }

    It 'Calls Get-Dns to discover the name servers for a zone' {
        Search-Dns @defaultParams

        Should -Invoke Get-Dns -ParameterFilter { $RecordType -eq 'NS' } @module
    }

    It 'Calls Get-Dns once for each discovered name server' {
        Search-Dns @defaultParams

        Should -Invoke Get-Dns -ParameterFilter { $RecordType -ne 'NS' } -Times 2 @module
    }
}
