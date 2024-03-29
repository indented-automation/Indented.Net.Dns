Describe DnsOPENPGPKEYRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'AQMFD5raczCJHViKtLYhWGz8hMY9UGRuniJDBzC7w0aRyzWZriO6i2odGWWQVucZqKVsENW91IOW4vqudngPZsY3GvQ/xVA8/7pyFj6b7Esga60zyGW6LFe9r8n6paHrlG5ojqf0BaqHT+8='
            RecordData = 'AQMFD5raczCJHViKtLYhWGz8hMY9UGRuniJDBzC7w0aRyzWZriO6i2od GWWQVucZqKVsENW91IOW4vqudngPZsY3GvQ/xVA8/7pyFj6b7Esga60z yGW6LFe9r8n6paHrlG5ojqf0BaqHT+8='
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsOPENPGPKEYRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}

