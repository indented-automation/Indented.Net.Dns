Describe Trace-Dns {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        $defaultParams = @{
            Name       = 'www.domain.com.'
            RecordType = 'A'
        }
    }

    BeforeEach {
        $Script:i = 0
    }

    Context 'Successful trace' {
        BeforeAll {
            Mock Get-Dns @module {
                if ($Script:i -lt 3) {
                    [PSCustomObject]@{
                        Header = [PSCustomObject]@{
                            RCode          = 'NOERROR'
                            AnswerCount    = 0
                            AuthorityCount = 1
                        }
                        Authority = @(
                            [PSCustomObject]@{
                                Hostname = 'ns1.domain.com.'
                            }
                        )
                    }
                } else {
                    [PSCustomObject]@{
                        Header = [PSCustomObject]@{
                            RCode          = 'NOERROR'
                            AnswerCount    = 1
                            AuthorityCount = 0
                        }
                    }
                }

                $Script:i++
            }
        }

        It 'Calls Get-Dns and follows authority records until answer count is greater than 0' {
            $dnsResponse = @(Trace-Dns @defaultParams)

            $dnsResponse.Count | Should -Be 4

            Should -Invoke Get-Dns -Times 4 @module
        }
    }

    Context 'Unsuccessful trace' {
        BeforeAll {
            Mock Get-Dns @module {
                if ($Script:i -lt 2) {
                    [PSCustomObject]@{
                        Header = [PSCustomObject]@{
                            RCode          = 'NOERROR'
                            AnswerCount    = 0
                            AuthorityCount = 1
                        }
                        Authority = @(
                            [PSCustomObject]@{
                                Hostname = 'ns1.domain.com.'
                            }
                        )
                    }
                } else {
                    [PSCustomObject]@{
                        Header = [PSCustomObject]@{
                            RCode          = 'NXDOMAIN'
                            AnswerCount    = 0
                            AuthorityCount = 0
                        }
                    }
                }

                $Script:i++
            }
        }

        It 'Aborts the trace if any response is unsuccess' {
            $dnsResponse = @(Trace-Dns @defaultParams)

            $dnsResponse.Count | Should -Be 3

            Should -Invoke Get-Dns -Times 3 @module
        }
    }
}
