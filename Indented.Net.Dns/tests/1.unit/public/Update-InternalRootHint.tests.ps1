Describe Update-InternalRootHint {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        Mock Invoke-WebRequest @module
        Mock Initialize-InternalDnsCache @module
    }

    It 'Downloads and updates named.root from internic' {
        Update-InternalRootHint

        Should -Invoke Invoke-WebRequest @module
        Should -Invoke Initialize-InternalDnsCache @module
    }
}
