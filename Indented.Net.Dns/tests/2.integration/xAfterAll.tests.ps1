Describe AfterAll {
    BeforeAll {
        & (Join-Path $PSScriptRoot 'script\Stop-NameServer.ps1')
    }

    It 'DNS service cleanup should be complete' {
        Get-Process named -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
}
