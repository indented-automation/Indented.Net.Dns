InModuleScope Indented.Net.Dns {
    Describe DnsNINFORecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'A2Zvbw==';     RecordData = '"foo"' }
            @{ Message = 'A2ZvbwNiYXI='; RecordData = '"foo" "bar"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNINFORecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
