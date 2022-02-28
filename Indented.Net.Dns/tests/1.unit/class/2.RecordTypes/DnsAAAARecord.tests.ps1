Describe DnsAAAARecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAAAAAAAAAAAAAAAAAAAAQ=='; RecordData = '::1' }
        @{ Message = 'KgAUUEAJCAEAAAAAAAAgBA=='; RecordData = '2a00:1450:4009:801::2004' }
        @{ Message = '/////////////////////w=='; RecordData = 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsAAAARecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
