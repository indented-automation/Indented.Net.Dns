InModuleScope Indented.Net.Dns {
    Describe DnsNXTRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AWEGc2VjdXJlA25pbAAiAQBGAAI='; RecordData = 'a.secure.nil. NS SOA MX KEY LOC NXT RRSIG' }
            @{ Message = 'AAAAAQI=';                     RecordData = '. NSAP-PTR NXT' }
            @{ Message = 'AEA=';                         RecordData = '. A' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNXTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
