InModuleScope Indented.Net.Dns {
    Describe DnsRTRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAARaW50ZXJtZWRpYXRlLWhvc3QEdGVzdAhpbmRlbnRlZAJjbwJ1awA=';  RecordData = '0 intermediate-host.test.indented.co.uk.' }
            @{ Message = '//8A';                                                      RecordData = '65535 .' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsRTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
