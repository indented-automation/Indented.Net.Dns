InModuleScope Indented.Net.Dns {
    Describe DnsNIMLOCRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'YW55dGhpbmc='; RecordData = '616E797468696E67' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNIMLOCRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
