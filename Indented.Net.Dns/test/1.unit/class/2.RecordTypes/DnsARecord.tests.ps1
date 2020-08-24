InModuleScope Indented.Net.Dns {
    Describe DnsARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAA=='; RecordData = '0.0.0.0' }
            @{ Message = 'wKgUHg=='; RecordData = '192.168.20.30' }
            @{ Message = '/////w=='; RecordData = '255.255.255.255' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
