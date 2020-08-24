InModuleScope Indented.Net.Dns {
    Describe DnsDNAMERecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'BmRvbWFpbgdleGFtcGxlAA=='; RecordData = 'domain.example.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsDNAMERecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
