Describe DnsKXRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAoDa2RjBHRlc3QIaW5kZW50ZWQCY28CdWsA'; RecordData = '10 kdc.test.indented.co.uk.' }
        @{ Message = 'AAoA'; RecordData = '10 .' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsKXRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
