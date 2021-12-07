Describe Add-InternalDnsCacheRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Initialize-InternalDnsCache
    }

    AfterAll {
        Initialize-InternalDnsCache
    }

    It 'Can add an instance of DnsCacheRecord to the cache' {
        $cacheRecord = InModuleScope @module {
            [DnsCacheRecord]@{
                Name       = 'cacherecordname.'
                IPAddress  = '1.2.3.4'
                RecordType = 'A'
                TTL        = 5
            }
        }

        $cacheRecord | Add-InternalDnsCacheRecord

        InModuleScope @module {
            $Script:dnsCache.Contains('cacherecordname.')
        } | Should -BeTrue
    }

    It 'Can add a cache record based on a A Record' {
        $dnsARecord = InModuleScope @module {
            [DnsARecord]@{
                Name      = 'arecordname.'
                IPAddress = '1.2.3.4'
            }
        }

        $dnsARecord | Add-InternalDnsCacheRecord

        InModuleScope @module {
            $Script:dnsCache.Contains('arecordname.')
        } | Should -BeTrue
    }

    It 'Can add a cache record based on an AAAA Record' {
        $dnsAAAARecord = InModuleScope @module {
            [DnsAAAARecord]@{
                Name      = 'aaaarecordname.'
                IPAddress = '1.2.3.4'
            }
        }

        $dnsAAAARecord | Add-InternalDnsCacheRecord

        InModuleScope @module {
            $Script:dnsCache.Contains('aaaarecordname.')
        } | Should -BeTrue
    }

    It 'Can permanently add a record to the cache' {
        $dnsARecord = InModuleScope @module
            [DnsARecord]@{
                Name      = 'apermanentrecordname.'
                IPAddress = '1.2.3.4'
            }
        }

        $dnsARecord | Add-InternalDnsCacheRecord -Permanent

        InModuleScope @module {
            $Script:dnsCache.Contains('apermanentrecordname.')
        } | Should -BeTrue
        InModuleScope @module {
            $Script:dnsCache['apermanentrecordname.'].IsPermanent
        } | Should -BeTrue
    }
}
