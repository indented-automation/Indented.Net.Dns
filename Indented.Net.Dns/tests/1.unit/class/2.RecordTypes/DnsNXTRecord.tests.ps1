Describe DnsNXTRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AWEGc2VjdXJlA25pbAAiAQBGAAI='; RecordData = 'a.secure.nil. NS SOA MX KEY LOC NXT RRSIG' }
        @{ Message = 'AAAAAQI='; RecordData = '. NSAP-PTR NXT' }
        @{ Message = 'AEA='; RecordData = '. A' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNXTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
