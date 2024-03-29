Describe DnsAMTRELAYRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'CgHLAHEP'; RecordData = '10 0 1 203.0.113.15' }
        @{ Message = 'CgIgAQ24AAAAAAAAAAAAAAAV'; RecordData = '10 0 2 2001:DB8::15' }
        @{ Message = 'gIMJYW10cmVsYXlzB2V4YW1wbGUDY29tAA=='; RecordData = '128 1 3 amtrelays.example.com.' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsAMTRelayRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
