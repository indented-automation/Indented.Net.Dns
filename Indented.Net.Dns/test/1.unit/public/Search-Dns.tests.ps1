InModuleScope Indented.Net.Dns {
    Describe Search-Dns {
        BeforeAll {
            Mock Get-Dns -ParameterFilter { $RecordType -eq 'NS' } {
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
            Mock Get-Dns -ParameterFilter { $RecordType -ne 'NS' }

            $defaultParams = @{
                Name       = 'www.domain.com.'
                ZoneName   = 'domain.com.'
                RecordType = 'A'
            }
        }

        It 'Calls Get-Dns to discover the name servers for a zone' {
            Search-Dns @defaultParams

            Assert-MockCalled Get-Dns -ParameterFilter { $RecordType -eq 'NS' } -Times 1 -Scope It
        }

        It 'Calls Get-Dns once for each discovered name server' {
            Search-Dns @defaultParams

            Assert-MockCalled Get-Dns -ParameterFilter { $RecordType -ne 'NS' } -Times 2 -Scope It
        }
    }
}
