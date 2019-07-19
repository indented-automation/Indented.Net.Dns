#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

InModuleScope Indented.Net.Dns {
    Describe DnsRRSIGRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'AC8BAwAADhA4bsAlMq6IRAhfA2ZvbwNuaWwAMxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6VAuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
                RecordData = 'NSEC 1 3 3600 20000102030405 19961211100908 2143 foo.nil. MxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6V AuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsRRSIGRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }

    It 'Can write the RRSIG record <RecordData> string in a long format' -TestCases @(
        @{
            Message    = 'AC8BAwAADhA4bsAlMq6IRAhfA2ZvbwNuaWwAMxFcby9k/yvedMfQgKzhH5er0Mu/vILz45IkskceFGgiWCn/GxHhai6VAuHAoNUz4YoU1tVfSCSqQYn6//11U6Nld80jEeC8aTrO+KKmCaY='
            RecordData = @(
                'NSEC 1 3 ( ; type-cov=NSEC, alg=RSAMD5, labels=3'
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
        param (
            $Message,
            $RecordData
        )

        $recordDataBytes = [Convert]::FromBase64String($Message)
        $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
        $resourceRecord = [DnsRRSIGRecord]::new()
        $resourceRecord.RecordDataLength = $recordDataBytes.Count
        $resourceRecord.ReadRecordData($binaryReader)

        $resourceRecord.ToLongString() | Should -Be $RecordData
}
}