InModuleScope Indented.Net.Dns {
    Describe DnsCERTRecord {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.Net.Dns'
            }
        }

        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = '//7///4zEVxvL2T/K950x9CArOEfl6vQy7+8gvPjkiSyRx4UaCJYKf8bEeFqLpUC4cCg1TPhihTW1V9IJKpBifr//XVTo2V3zSMR4LxpOs74oqYJpg==';
                RecordData = '65534 65535 PRIVATEOID MxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6V AuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsCERTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
