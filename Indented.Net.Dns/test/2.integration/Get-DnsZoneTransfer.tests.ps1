'server 127.0.0.1 1053', 'update add a99.test2.indented.co.uk. 3600 A 1.2.3.4', 'send' | .\bin\nsupdate --% -y hmac-sha256:ddns-key:5mJtXnJvb/1FDQQ/5jiB+WellbkBLazVEdIssxAsg1Q= -L 9

Describe Get-Dns -Tag Integration {
    Context 'Named' {
        BeforeAll {
            & (Join-Path $psscriptroot 'script\Start-NameServer.ps1')

            $nsupdate = Join-Path $psscriptroot 'bin\nsupdate.exe'

            @(
                'server 127.0.0.1 1053'
                'update add a98.test2.indented.co.uk. 3600 A 1.2.3.4'
                'send'
            ) | & $nsupdate -y hmac-sha256:ddns-key:5mJtXnJvb/1FDQQ/5jiB+WellbkBLazVEdIssxAsg1Q= -L 9

            $defaultParams = @{
                ZoneName     = 'test2.indented.co.uk'
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
            $soaRecords.Count | Should -BeGreaterThan 2
        }
    }
}