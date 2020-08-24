InModuleScope Indented.Net.Dns {
    Describe DnsTSIGRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'BnNhbXBsZQhhbGdvcml0aAAAADKuiEQBLAAB/wD/AAAAAYA='
                RecordData = 'sample.algorith. 19961211100908 300 FF 255 0 80'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsTSIGRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
