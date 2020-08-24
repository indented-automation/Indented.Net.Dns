InModuleScope Indented.Net.Dns {
    Describe DnsNSAPPTRRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'A2ZvbwA='; RecordData = 'foo.' }
            @{ Message = 'AA==';     RecordData = '.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNSAPPTRRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
