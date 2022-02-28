Describe DnsIPSECKEYRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'CgECwAACJgEDUVN5hu01UztgZEeO7rJ7W9dNrhSbboG6OgUhr4KreAE='
            RecordData = '10 1 2 192.0.2.38 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ=='
        }
        @{
            Message    = 'CgACAQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ=='
            RecordData = '10 0 2 . AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ=='
        }
        @{
            Message    = 'CgECwAACAwEDUVN5hu01UztgZEeO7rJ7W9dNrhSbboG6OgUhr4KreAE='
            RecordData = '10 1 2 192.0.2.3 AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ=='
        }
        @{
            Message    = 'CgMCCW15Z2F0ZXdheQdleGFtcGxlA2NvbQABA1FTeYbtNVM7YGRHju6ye1vXTa4Um26BujoFIa+Cq3gB'
            RecordData = '10 3 2 mygateway.example.com. AQNRU3mG7TVTO2BkR47usntb102uFJtugbo6BSGvgqt4AQ=='
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsIPSECKEYRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
