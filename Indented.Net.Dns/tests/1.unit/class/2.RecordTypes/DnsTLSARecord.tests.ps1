Describe DnsTLSARecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'AQECkgA7o0lC3HQVLi8sQI0p7KWlIOfy4Gu5RPTco0a69jwbF3YV1Gb2xLccIWpQKSvVjJ690vdOOP5R/9SMQzJsvA=='
            RecordData = '1 1 2 92003BA34942DC74152E2F2C408D29ECA5A520E7F2E06BB944F4DCA3 46BAF63C1B177615D466F6C4B71C216A50292BD58C9EBDD2F74E38FE 51FFD48C43326CBC'
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsTLSARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
