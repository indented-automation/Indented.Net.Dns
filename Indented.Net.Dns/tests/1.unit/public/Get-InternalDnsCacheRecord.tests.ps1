Describe Get-InternalDnsCacheRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Initialize-InternalDnsCache

        InModuleScope @module {
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
    }

    AfterAll {
        Initialize-InternalDnsCache
    }

    It 'Gets all cached resources' {
        Get-InternalDnsCacheRecord | Should -Not -BeNullOrEmpty

        $cachedRecords = InModuleScope @module {
            $Script:dnsCache.Values | Write-Output
        }
        @(Get-InternalDnsCacheRecord).Count | Should -Be @($cachedRecords).Count
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
}
