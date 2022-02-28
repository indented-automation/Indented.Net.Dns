Describe DnsWINSRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAAAAAAAAAIAAA4QAAAAAQECAwQ='; RecordData = 'L2 C3600 ( 1.2.3.4 )' }
        @{ Message = 'AAEAAAAAAAIAAA4QAAAAAQECAwQ='; RecordData = 'LOCAL L2 C3600 ( 1.2.3.4 )' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsWINSRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
