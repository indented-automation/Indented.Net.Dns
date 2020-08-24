InModuleScope Indented.Net.Dns {
    Describe Add-InternalDnsCacheRecord {
        BeforeAll {
            Initialize-InternalDnsCache
        }

        AfterAll {
            Initialize-InternalDnsCache
        }

        It 'Can add an instance of DnsCacheRecord to the cache' {
            $cacheRecord = [DnsCacheRecord]@{
                Name       = 'cacherecordname.'
                IPAddress  = '1.2.3.4'
                RecordType = 'A'
                TTL        = 5
            }

            $cacheRecord | Add-InternalDnsCacheRecord

            $Script:dnsCache.Contains('cacherecordname.') | Should -BeTrue
        }

        It 'Can add a cache record based on a A Record' {
            $dnsARecord = [DnsARecord]@{
                Name      = 'arecordname.'
                IPAddress = '1.2.3.4'
            }

            $dnsARecord | Add-InternalDnsCacheRecord

            $Script:dnsCache.Contains('arecordname.') | Should -BeTrue
        }

        It 'Can add a cache record based on an AAAA Record' {
            $dnsAAAARecord = [DnsAAAARecord]@{
                Name      = 'aaaarecordname.'
                IPAddress = '1.2.3.4'
            }

            $dnsAAAARecord | Add-InternalDnsCacheRecord

            $Script:dnsCache.Contains('aaaarecordname.') | Should -BeTrue
        }

        It 'Can permanently add a record to the cache' {
            $dnsARecord = [DnsARecord]@{
                Name      = 'apermanentrecordname.'
                IPAddress = '1.2.3.4'
            }

            $dnsARecord | Add-InternalDnsCacheRecord -Permanent

            $Script:dnsCache.Contains('apermanentrecordname.') | Should -BeTrue
            $Script:dnsCache['apermanentrecordname.'].IsPermanent | Should -BeTrue
        }
    }
}
