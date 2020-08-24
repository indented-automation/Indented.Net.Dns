InModuleScope Indented.Net.Dns {
    Describe DnsNIDRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAoAFE///yDuZA=='; RecordData = '10 14:4fff:ff20:ee64' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNIDRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
