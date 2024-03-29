Describe DnsSRVRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAAAAAAAAA=='; RecordData = '0 0 0 .' }
        @{ Message = 'AGQAMgAKBV9sZGFwBmRvbWFpbgdleGFtcGxlAA=='; RecordData = '100 50 10 _ldap.domain.example.' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsSRVRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
