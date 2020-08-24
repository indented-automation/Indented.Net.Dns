InModuleScope Indented.Net.Dns {
    Describe DnsCNAMERecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'A3d3dwZkb21haW4HZXhhbXBsZQA='; RecordData = 'www.domain.example.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsCNAMERecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
