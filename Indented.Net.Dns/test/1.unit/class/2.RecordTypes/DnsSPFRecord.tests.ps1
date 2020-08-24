InModuleScope Indented.Net.Dns {
    Describe DnsSPFRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'JnY9c3BmMSBpbmNsdWRlOnNwZi5kb21haW4uZXhhbXBsZSB+YWxs'; RecordData = '"v=spf1 include:spf.domain.example ~all"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsSPFRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
