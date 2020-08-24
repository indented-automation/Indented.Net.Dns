InModuleScope Indented.Net.Dns {
    Describe DnsAVCRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'B2ZvbzpiYXI='; RecordData = '"foo:bar"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsAVCRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
