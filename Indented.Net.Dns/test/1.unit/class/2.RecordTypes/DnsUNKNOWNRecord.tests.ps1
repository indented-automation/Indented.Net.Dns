InModuleScope Indented.Net.Dns {
    Describe DnsUnknownRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'YW55dGhpbmc='; RecordData = 'YW55dGhpbmc=' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsUnknownRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
