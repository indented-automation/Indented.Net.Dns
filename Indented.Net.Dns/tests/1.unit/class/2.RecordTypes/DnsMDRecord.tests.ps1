Describe DnsMDRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'A3d3dwZkb21haW4HZXhhbXBsZQA='; RecordData = 'www.domain.example.' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsMDRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
