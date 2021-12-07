Describe AfterAll {
    BeforeAll {
        & (Join-Path $PSScriptRoot 'script\Stop-NameServer.ps1')
    }
}
