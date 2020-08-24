InModuleScope Indented.Net.Dns {
    Describe DnsKXRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAoDa2RjBHRlc3QIaW5kZW50ZWQCY28CdWsA'; RecordData = '10 kdc.test.indented.co.uk.' }
            @{ Message = 'AAoA';                                 RecordData = '10 .' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsKXRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
