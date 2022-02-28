Describe DnsOPTRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = ''; RecordData = '' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsOPTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }

    It 'Converts to a resource record to bytes' {
        $resourceRecord = InModuleScope @module {
            [DnsOPTRecord]@{
                MaximumPayloadSize = 4096
                Z                  = 'DO'
            }
        }

        [Convert]::ToBase64String($resourceRecord.ToByteArray()) | Should -Be 'AAApEAAAAIAAAAA='
    }
}
