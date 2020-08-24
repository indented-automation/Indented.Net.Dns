InModuleScope Indented.Net.Dns {
    Describe DnsSSHFPRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'BALHbYMplU2ig1dR43FUTpY+/aCZCA1sWN0r/ZoxbhYsgw=='
                RecordData = '4 2 C76D8329954DA2835751E371544E963EFDA099080D6C58DD2BFD9A31 6E162C83'
            }
            @{
                Message    = 'AQK/KUaMg6xYzPjIWrezvrBU7PHjhRK4NTqzZHH6iJYdzA=='
                RecordData = '1 2 BF29468C83AC58CCF8C85AB7B3BEB054ECF1E38512B8353AB36471FA 88961DCC'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsSSHFPRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
