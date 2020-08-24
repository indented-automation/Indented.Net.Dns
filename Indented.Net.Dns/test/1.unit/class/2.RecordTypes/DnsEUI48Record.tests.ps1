InModuleScope Indented.Net.Dns {
    Describe DnsEUI48Record {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'ASNFZ4mr'; RecordData = '01-23-45-67-89-ab' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsEUI48Record]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
