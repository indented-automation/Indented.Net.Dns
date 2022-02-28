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
        InModuleScope @module { $Script:dnsCache.Count } | Should -BeGreaterThan 0

        Clear-InternalDnsCache

        InModuleScope @module { $Script:dnsCache.Count } | Should -Be 0
    }

    It 'Can be used to remove expired entries only' {
        InModuleScope @module { $Script:dnsCache.Count } | Should -BeGreaterThan 0
        InModuleScope @module {
            $Script:dnsCache.Add(
                'expiringrecordname.',
                [DnsCacheRecord]@{
                    Name       = 'expiringrecordname.'
                    IPAddress  = '1.2.3.4'
                    RecordType = 'A'
                    TTL        = 0
                }
            )
        }

        Clear-InternalDnsCache -ExpiredOnly

        InModuleScope @module { $Script:dnsCache.Count } | Should -BeGreaterThan 0
        InModuleScope @module { $Script:dnsCache.Contains('expiringrecordname.') } | Should -BeFalse
    }
}
