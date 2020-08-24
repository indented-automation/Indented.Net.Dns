InModuleScope Indented.Net.Dns {
    Describe DnsLPRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAoHZXhhbXBsZQNuZXQA'; RecordData = '10 example.net.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsLPRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
