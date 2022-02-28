Describe DnsTALINKRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'AAd0YWxpbmsxBHRlc3QIaW5kZW50ZWQCY28CdWsA'; RecordData = '. talink1.test.indented.co.uk.' }
        @{ Message = 'B3RhbGluazAEdGVzdAhpbmRlbnRlZAJjbwJ1awAHdGFsaW5rMgR0ZXN0CGluZGVudGVkAmNvAnVrAA=='; RecordData = 'talink0.test.indented.co.uk. talink2.test.indented.co.uk.' }
        @{ Message = 'B3RhbGluazIEdGVzdAhpbmRlbnRlZAJjbwJ1awAA'; RecordData = 'talink2.test.indented.co.uk. .' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsTALINKRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
