InModuleScope Indented.Net.Dns {
    Describe DnsNSEC3Record {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'AQAACgRQU4UbFCOoYJQQufu3X9nqFk8Irh4JedGJAAciAAAAAAKQ/yAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAg=='
                RecordData = '1 0 10 5053851B 4EK6150GN7TRENUPT8B4U25E3O4NJKC9 NS SOA RRSIG DNSKEY NSEC3PARAM TYPE65534'
            }
            @{
                Message    = 'AQAACgRQU4UbFHRMHDEHjAvVDCHdh7YzWKmgDQ2hAAZAAAAAAAI='
                RecordData = '1 0 10 5053851B EH61OC87HG5TA311RM3RCCQOL6G0Q3D1 A RRSIG'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNSEC3Record]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
