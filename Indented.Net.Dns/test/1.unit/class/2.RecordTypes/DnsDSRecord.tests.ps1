InModuleScope Indented.Net.Dns {
    Describe DnsDSRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'MlwFAXqko/QWwvI5H7erDUNPdizWLROQ';                     RecordData = '12892 5 1 7AA4A3F416C2F2391FB7AB0D434F762CD62D1390' }
            # @{ Message = 'MlwFAiZYSDXKgMgckZmfMc+vKg6J1P8cj6/Q3bMahccAGSd8Ew=='; RecordData = '12892 5 2 26584835CA80C81C91999F31CFAF2A0E89D4FF1C8FAFD0DDB31A85C7 19277C13' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsDSRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
