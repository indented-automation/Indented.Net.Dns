InModuleScope Indented.Net.Dns {
    Describe DnsMINFORecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'B3JtYWlsYngHZXhhbXBsZQAHZW1haWxieAdleGFtcGxlAA=='; RecordData = 'rmailbx.example. emailbx.example.' }
            @{ Message = 'AAA=';                                             RecordData = '. .' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsMINFORecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
