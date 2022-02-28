Describe DnsA6Record {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AP////////////////////8GZG9tYWluBG5hbWUA'; RecordData = '0 ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff domain.name.' }
        @{ Message = 'QP//////////BmRvbWFpbgRuYW1lAA=='; RecordData = '64 ::ffff:ffff:ffff:ffff domain.name.' }
        @{ Message = 'fwEGZG9tYWluBG5hbWUA'; RecordData = '127 ::1 domain.name.' }
        @{ Message = 'gAZkb21haW4EbmFtZQA='; RecordData = '128  domain.name.' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsA6Record]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
