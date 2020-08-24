InModuleScope Indented.Net.Dns {
    Describe DnsMXRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAoDbXgxBmRvbWFpbgdleGFtcGxlAA=='; RecordData = '10 mx1.domain.example.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsMXRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
