InModuleScope Indented.Net.Dns {
    Describe DnsEUI64Record {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'ASNFZ4mrze8='; RecordData = '01-23-45-67-89-ab-cd-ef' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsEUI64Record]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
