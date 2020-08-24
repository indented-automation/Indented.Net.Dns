InModuleScope Indented.Net.Dns {
    Describe DnsUNSPECRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'BA=='; RecordData = '\# 1 04' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsUNSPECRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
