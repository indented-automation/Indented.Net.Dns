Describe DnsAFSDBRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAEGZG9tYWluBG5hbWUA'; RecordData = '1 domain.name.' }
        @{ Message = 'AAIGZG9tYWluBG5hbWUA'; RecordData = '2 domain.name.' }
        @{ Message = '//8GZG9tYWluBG5hbWUA'; RecordData = '65535 domain.name.' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsAFSDBRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
