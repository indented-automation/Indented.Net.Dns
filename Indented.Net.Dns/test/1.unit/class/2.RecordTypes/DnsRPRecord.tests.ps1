InModuleScope Indented.Net.Dns {
    Describe DnsRPRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'Cm1ib3gtZG5hbWUEdGVzdAhpbmRlbnRlZAJjbwJ1awAJdHh0LWRuYW1lBHRlc3QIaW5kZW50ZWQCY28CdWsA'
                RecordData = 'mbox-dname.test.indented.co.uk. txt-dname.test.indented.co.uk.'
            }
            @{
                Message    = 'AAA='
                RecordData = '. .'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsRPRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
