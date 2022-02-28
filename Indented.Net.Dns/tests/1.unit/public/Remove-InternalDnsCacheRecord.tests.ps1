Describe Remnove-InternalDnsCacheRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Initialize-InternalDnsCache

        InModuleScope @module {
            $Script:dnsCache.Add(
                'recordtoremove1.',
                @(
                    [DnsCacheRecord]@{
                        Name       = 'recordtoremove1.'
                        IPAddress  = '1.2.3.4'
                        RecordType = 'A'
                        TTL        = 0
                    }
                )
            )
            $Script:dnsCache.Add(
                'recordtoremove2.',
                @(
                    [DnsCacheRecord]@{
                        Name       = 'recordtoremove2.'
                        IPAddress  = '1.2.3.4'
                        RecordType = 'A'
                        TTL        = 0
                    }
                    [DnsCacheRecord]@{
                        Name       = 'recordtoremove2.'
                        IPAddress  = '::1'
                        RecordType = 'AAAA'
                        TTL        = 0
                    }
                )
            )
            $Script:dnsCache.Add(
                'recordtoremove3.',
                @(
                    [DnsCacheRecord]@{
                        Name       = 'recordtoremove3.'
                        IPAddress  = '1.2.3.4'
                        RecordType = 'A'
                        TTL        = 0
                    }
                )
            )
        }
    }

    AfterAll {
        Initialize-InternalDnsCache
    }

    It 'Removes a single name from the cache' {
        Remove-InternalDnsCacheRecord -Name recordtoremove1.

        InModuleScope @module { $Script:dnsCache.Contains('recordtoremove1.') } | Should -BeFalse
    }

    It 'Removes a specific name and record type from' {
        Remove-InternalDnsCacheRecord -Name recordtoremove2. -RecordType A

        InModuleScope @module { $Script:dnsCache.Contains('recordtoremove2.') } | Should -BeTrue
        InModuleScope @module { $Script:dnsCache['recordtoremove2.'].RecordType } | Should -Be 'AAAA'
    }

    It 'Removes a name from the cache when all records for the name are removed' {
        Remove-InternalDnsCacheRecord -Name recordtoremove3. -RecordType A

        InModuleScope @module { $Script:dnsCache.Contains('recordtoremove3.') } | Should -BeFalse
    }
}
