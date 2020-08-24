InModuleScope Indented.Net.Dns {
    Describe DnsWINSRRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAAAAAAIAAA4QBHRlc3QIaW5kZW50ZWQCY28CdWsA'; RecordData = 'L2 C3600 ( test.indented.co.uk. )' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsWINSRRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
