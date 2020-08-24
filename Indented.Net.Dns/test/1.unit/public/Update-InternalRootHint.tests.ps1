InModuleScope Indented.Net.Dns {
    Describe Update-InternalRootHint {
        BeforeAll {
            Mock Invoke-WebRequest
            Mock Initialize-InternalDnsCache
        }

        It 'Downloads and updates named.root from internic' {
            Update-InternalRootHint

            Assert-MockCalled Invoke-WebRequest
            Assert-MockCalled Initialize-InternalDnsCache
        }
    }
}
