InModuleScope Indented.Net.Dns {
    Describe DnsAPLRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAEYAQo=';             RecordData = '1:10.0.0.0/24' }
            @{ Message = 'AAEghAoAAAEAARgBCg=='; RecordData = '!1:10.0.0.1/32 1:10.0.0.0/24' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsAPLRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
