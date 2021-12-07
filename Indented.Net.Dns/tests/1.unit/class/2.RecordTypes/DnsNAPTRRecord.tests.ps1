InModuleScope Indented.Net.Dns {
    Describe DnsNAPTRRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAAAAAAA=';                             RecordData = '0 0 "" "" "" .' }
            @{ Message = '/////wZibHVyZ2gFYmxvcmYGYmxsbGJiA2ZvbwA='; RecordData = '65535 65535 "blurgh" "blorf" "blllbb" foo.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNAPTRRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
