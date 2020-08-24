InModuleScope Indented.Net.Dns {
    Describe DnsISDNRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'DGlzZG4tYWRkcmVzcw==';             RecordData = '"isdn-address"' }
            @{ Message = 'DGlzZG4tYWRkcmVzcwpzdWJhZGRyZXNz'; RecordData = '"isdn-address" "subaddress"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsISDNRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
