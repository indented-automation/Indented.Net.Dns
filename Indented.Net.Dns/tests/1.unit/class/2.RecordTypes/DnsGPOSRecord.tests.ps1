InModuleScope Indented.Net.Dns {
    Describe DnsGPOSRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAA';                             RecordData = '"" "" ""' }
            @{ Message = 'CC0yMi42ODgyCDExNi44NjUyBTI1MC4w'; RecordData = '"-22.6882" "116.8652" "250.0"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsGPOSRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
