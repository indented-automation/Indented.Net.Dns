Describe AfterAll {
    BeforeAll {
        & (Join-Path $psscriptroot 'script\Stop-NameServer.ps1')
    }
}