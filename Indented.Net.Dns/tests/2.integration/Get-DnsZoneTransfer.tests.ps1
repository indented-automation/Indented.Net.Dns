Describe Get-DnsZoneTransfer -Tag Integration {
    BeforeAll {
        & (Join-Path $PSScriptRoot 'script\Start-NameServer.ps1')

        $nsupdate = Join-Path $PSScriptRoot 'bin\nsupdate.exe'

        @(
            'server 127.0.0.1 1053'
            'update add a100.insecure.indented.co.uk. 3600 A 1.2.3.4'
            'update add a101.insecure.indented.co.uk. 3600 A 1.2.3.4'
            'send'
        ) | & $nsupdate

        $defaultParams = @{
            ZoneName     = 'insecure.indented.co.uk.'
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
        $getParams = $defaultParams.Clone()
        $getParams.Name = $getParams.ZoneName
        $getParams.RecordType = 'SOA'
        $getParams.Remove('ZoneName')
        $serial = (Get-Dns @getParams).Answer[0].Serial

        @(
            'server 127.0.0.1 1053'
            'update add a102.insecure.indented.co.uk. 3600 A 1.2.3.4'
            'update add a103.insecure.indented.co.uk. 3600 A 1.2.3.4'
            'send'
        ) | & $nsupdate

        $dnsResponse = Get-DnsZoneTransfer @defaultParams -SerialNumber $serial

        $dnsResponse.Question[0].RecordType | Should -Be 'IXFR'
        $dnsResponse.Header.RCode | Should -Be 'NoError'
        $dnsResponse.Header.AnswerCount | Should -BeGreaterThan 0

        $soaRecords = $dnsResponse.Answer | Where-Object RecordType -eq 'SOA'
        $soaRecords.Count | Should -BeGreaterThan 2
    }
}
