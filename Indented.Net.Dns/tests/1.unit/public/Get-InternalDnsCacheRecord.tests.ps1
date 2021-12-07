InModuleScope Indented.Net.Dns {
    Describe Get-InternalDnsCacheRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }

            Initialize-InternalDnsCache

            $Script:dnsCache.Add(
                'addressresourcetype.',
                [DnsCacheRecord]@{
                    Name       = 'addressresourcetype.'
                    IPAddress  = '1.2.3.4'
                    RecordType = 'A'
                    TTL        = 0
                }
            )
        }

        It 'Gets all cached resources' {
            Get-InternalDnsCacheRecord | Should -Not -BeNullOrEmpty

            $cachedRecords = @($Script:dnsCache.Values | ForEach-Object { $_ })
            @(Get-InternalDnsCacheRecord).Count | Should -Be $cachedRecords.Count
        }

        It 'Gets records by name' {
            Get-InternalDnsCacheRecord -Name addressresourcetype. | Should -Not -BeNullOrEmpty
        }

        It 'Gets records by ResourceType' {
            Get-InternalDnsCacheRecord -ResourceType Address | Should -Not -BeNullOrEmpty
            Get-InternalDnsCacheRecord -ResourceType Hint | Should -Not -BeNullOrEmpty
        }

        It 'Gets records by RecordType' {
            Get-InternalDnsCacheRecord -RecordType A | Should -Not -BeNullOrEmpty
            Get-InternalDnsCacheRecord -RecordType AAAA | Should -Not -BeNullOrEmpty
        }

        AfterAll {
            Initialize-InternalDnsCache
        }
    }
}
