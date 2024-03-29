Describe DnsNSECRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AWEGc2VjdXJlA25pbAAAByIBAAQAA4A='; RecordData = 'a.secure.nil. NS SOA MX LOC RRSIG NSEC DNSKEY' }
        @{ Message = 'AAAGAAABAAAB'; RecordData = '. NSAP-PTR NSEC' }
        @{ Message = 'AAABQA=='; RecordData = '. A' }
        @{ Message = 'AAAQAAAAAAAAAAAAAAAAAAAAAQ=='; RecordData = '. TYPE127' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNSECRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
