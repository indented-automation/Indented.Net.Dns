#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

Describe Get-DnsZoneTransfer -Tag Integration {
    BeforeAll {
        & (Join-Path $psscriptroot 'script\Start-NameServer.ps1')

        $nsupdate = Join-Path $psscriptroot 'bin\nsupdate.exe'

        @(
            'server 127.0.0.1 1053'
            'update add a98.signed.indented.co.uk. 3600 A 1.2.3.4'
            'update add a99.signed.indented.co.uk. 3600 A 1.2.3.4'
            'send'
            'update add a97.signed.indented.co.uk. 3600 A 1.2.3.4'
            'update add a96.signed.indented.co.uk. 3600 A 1.2.3.4'
            'send'
        ) | & $nsupdate -y hmac-sha256:ddns-key:5mJtXnJvb/1FDQQ/5jiB+WellbkBLazVEdIssxAsg1Q= -L 9 2>$null

        $defaultParams = @{
            ZoneName     = 'signed.indented.co.uk.'
            ComputerName = '127.0.0.1'
            Port         = 1053
        }
    }

    It 'Transfers zone using AXFR by default' {
        $dnsResponse = Get-DnsZoneTransfer @defaultParams

        $dnsResponse.Question[0].RecordType | Should -Be 'AXFR'
        $dnsResponse.Header.RCode | Should -Be 'NoError'
        $dnsResponse.Header.AnswerCount | Should -BeGreaterThan 0
    }

    It 'When given a serial number, performs an incremental zone transfer' {
        $dnsResponse = Get-DnsZoneTransfer @defaultParams -SerialNumber 1

        $dnsResponse.Question[0].RecordType | Should -Be 'IXFR'
        $dnsResponse.Header.RCode | Should -Be 'NoError'
        $dnsResponse.Header.AnswerCount | Should -BeGreaterThan 0

        $soaRecords = $dnsResponse.Answer | Where-Object RecordType -eq 'SOA'
        $soaRecords.Count | Should -BeGreaterOrEqual 2
    }
}