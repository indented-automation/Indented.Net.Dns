Describe Initialize-InternalDnsCacheRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    Context 'Mocked' {
        BeforeAll {
            Mock Get-Content @module {
                '.                        3600000      NS    A.ROOT-SERVERS.NET.'
                'A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4'
                'A.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:ba3e::2:30'
            }
            Mock Add-InternalDnsCacheRecord @module
        }

        AfterAll {
            Initialize-InternalDnsCache
        }

        It 'Imports named.root into the cache' {
            Initialize-InternalDnsCache

            Should -Invoke Get-Content @module
            Should -Invoke Add-InternalDnsCacheRecord @module
        }
    }
}
