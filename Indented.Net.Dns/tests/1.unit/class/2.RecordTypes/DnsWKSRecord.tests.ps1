InModuleScope Indented.Net.Dns {
    Describe DnsWKSRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'CgAAAQbgAAU=';     RecordData = '10.0.0.1 6 0 1 2 21 23' }
            @{ Message = 'CgAAARHgAAAAAAAE'; RecordData = '10.0.0.1 17 0 1 2 53' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsWKSRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
