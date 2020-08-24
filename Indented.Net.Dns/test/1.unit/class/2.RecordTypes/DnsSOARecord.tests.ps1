InModuleScope Indented.Net.Dns {
    Describe DnsSOARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'A25zMQdleGFtcGxlAApob3N0bWFzdGVyB2V4YW1wbGUAX215tQAAAAUAAAAFABuvgAAADhA='
                RecordData = 'ns1.example. hostmaster.example. 1601010101 5 5 1814400 3600'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsSOARecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }

        It 'Can write the SOA record <RecordData> string in a long format' -TestCases @(
                @{
                    Message    = 'A25zMQdleGFtcGxlAApob3N0bWFzdGVyB2V4YW1wbGUAX215tQAAAAUAAAAFABuvgAAADhA='
                    RecordData = @(
                        'ns1.example. hostmaster.example. ('
                        '    1601010101 ; serial'
                        '    5          ; refresh (5 seconds)'
                        '    5          ; retry (5 seconds)'
                        '    1814400    ; expire (3 weeks)'
                        '    3600       ; minimum ttl (1 hour)'
                        ')'
                    ) -join "`n"
                }
            ) {
                param (
                    $Message,
                    $RecordData
                )

                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                $resourceRecord = [DnsSOARecord]::new()
                $resourceRecord.ReadRecordData($binaryReader)

                $resourceRecord.ToLongString() | Should -Be $RecordData
        }
    }
}
