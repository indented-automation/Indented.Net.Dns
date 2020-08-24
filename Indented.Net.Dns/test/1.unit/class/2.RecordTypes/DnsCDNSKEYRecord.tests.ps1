InModuleScope Indented.Net.Dns {
    Describe DnsCDNSKEYRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'AgD/AQEDBQ+a2nMwiR1YirS2IVhs/ITGPVBkbp4iQwcwu8NGkcs1ma4juotqHRllkFbnGailbBDVvdSDluL6rnZ4D2bGNxr0P8VQPP+6chY+m+xLIGutM8hluixXva/J+qWh65RuaI6n9AWqh0/v'
                RecordData = '512 255 1 AQMFD5raczCJHViKtLYhWGz8hMY9UGRuniJDBzC7w0aRyzWZriO6i2od GWWQVucZqKVsENW91IOW4vqudngPZsY3GvQ/xVA8/7pyFj6b7Esga60z yGW6LFe9r8n6paHrlG5ojqf0BaqHT+8='
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsCDNSKEYRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
