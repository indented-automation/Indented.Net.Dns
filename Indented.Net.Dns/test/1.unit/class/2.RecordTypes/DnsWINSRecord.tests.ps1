InModuleScope Indented.Net.Dns {
    Describe DnsWINSRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAAAAAAIAAA4QAAAAAQECAwQ='; RecordData = 'L2 C3600 ( 1.2.3.4 )' }
            @{ Message = 'AAEAAAAAAAIAAA4QAAAAAQECAwQ='; RecordData = 'LOCAL L2 C3600 ( 1.2.3.4 )' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsWINSRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
