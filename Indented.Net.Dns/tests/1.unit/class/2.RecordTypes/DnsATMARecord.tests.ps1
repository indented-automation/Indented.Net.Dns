Describe DnsATMARecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'ATYxMjAwMDAwMDAw'; RecordData = '+61200000000' }
        @{ Message = 'ATYxMjAwMDAwMDAw'; RecordData = '+61200000000' }
        @{ Message = 'ABI0VniQq83v'; RecordData = '1234567890abcdef' }
        @{ Message = 'AP7cugmHZUMh'; RecordData = 'fedcba0987654321' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsATMARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
