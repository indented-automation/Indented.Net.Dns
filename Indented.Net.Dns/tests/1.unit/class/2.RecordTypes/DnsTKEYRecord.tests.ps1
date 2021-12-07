InModuleScope Indented.Net.Dns {
    Describe DnsTKEYRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'BnNhbXBsZQhhbGdvcml0aAAyrohEOG7AJQABAAAAAf8AAYA='
                RecordData = 'sample.algorith. 19961211100908 20000102030405 1 FF 80'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsTKEYRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
