InModuleScope Indented.Net.Dns {
    Describe DnsNSEC3PARAMRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AQAAAAA=';             RecordData = '1 0 0 -' }
            @{ Message = 'AQAAAQiGi89+1BCJKQ=='; RecordData = '1 0 1 868BCF7ED4108929' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNSEC3PARAMRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
