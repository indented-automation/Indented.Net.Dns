Describe DnsCAARecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAVpc3N1ZWNhLmV4YW1wbGUubmV0OyBwb2xpY3k9ZXY='; RecordData = '0 issue "ca.example.net; policy=ev"' }
        @{ Message = 'gAN0YnNVbmtub3du'; RecordData = '128 tbs "Unknown"' }
        @{ Message = 'gAN0YnM='; RecordData = '128 tbs ""' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsCAARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
