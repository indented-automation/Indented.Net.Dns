InModuleScope Indented.Net.Dns {
    Describe DnsPXRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAoDZm9vAANiYXIA'; RecordData = '10    foo. bar.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsPXRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
