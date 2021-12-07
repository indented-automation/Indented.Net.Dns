InModuleScope Indented.Net.Dns {
    Describe Clear-InternalDnsCacheRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        BeforeEach {
            Initialize-InternalDnsCache
        }

        AfterEach {
            Initialize-InternalDnsCache
        }

        It 'Can be used to clear all entries from the cache' {
            $Script:dnsCache.Count | Should -BeGreaterThan 0

            Clear-InternalDnsCache

            $Script:dnsCache.Count | Should -Be 0
        }

        It 'Can be used to remove expired entries only' {
            $Script:dnsCache.Count | Should -BeGreaterThan 0
            $Script:dnsCache.Add(
                'expiringrecordname.',
                [DnsCacheRecord]@{
                    Name       = 'expiringrecordname.'
                    IPAddress  = '1.2.3.4'
                    RecordType = 'A'
                    TTL        = 0
                }
            )

            Clear-InternalDnsCache -ExpiredOnly

            $Script:dnsCache.Count | Should -BeGreaterThan 0
            $Script:dnsCache.Contains('expiringrecordname.') | Should -BeFalse
        }
    }
}
