Describe DnsSIGRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'AB4BAwAADhA4bsAlMq6IRAhfA2ZvbwNuaWwAMxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6VAuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
            RecordData = 'NXT 1 3 3600 20000102030405 19961211100908 2143 foo.nil. MxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6V AuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsSIGRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }

    It 'Can write the SIG record <RecordData> string in a long format' -TestCases @(
            @{
                Message    = 'AB4BAwAADhA4bsAlMq6IRAhfA2ZvbwNuaWwAMxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6VAuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
                RecordData = @(
                    'NXT 1 3 ( ; type-cov=NXT, alg=RSAMD5, labels=3'
                    '    3600             ; OriginalTTL'
                    '    20000102030405   ; Signature expiration (2000-01-02 03:04:05Z)'
                    '    19961211100908   ; Signature inception (1996-12-11 10:09:08Z)'
                    '    2143             ; Key identifier'
                    '    foo.nil.         ; Signer'
                    '    MxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6V AuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY= ; Signature'
                    ')'
                ) -join "`n"
            }
        ) {
            $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
                $recordDataBytes = [Convert]::FromBase64String($Message)
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
                $resourceRecord = [DnsSIGRecord]::new()
                $resourceRecord.RecordDataLength = $recordDataBytes.Count
                $resourceRecord.ReadRecordData($binaryReader)
                $resourceRecord
            }

            $resourceRecord.ToLongString() | Should -Be $RecordData
    }
}
