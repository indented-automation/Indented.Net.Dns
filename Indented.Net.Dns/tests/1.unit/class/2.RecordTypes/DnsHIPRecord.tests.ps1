Describe DnsHIPRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{
            Message    = 'EAIAhCABABB7GnTfNlY5zDnx1XgDAQABt3HKE25K61zkQzPFOz0sE8IiQ4Ufxwi8zin34utXh7X1bMrTT4IjrMEJBN21ay7EptYjLztQ6glPCRSzuUG75SmvWCw2u63v2vKtr5tJEZBvWyUiYDxhUnK4gOyPuTDMbuOcRE2qdbFnjwBaSySZ0dpUM/gFx6WtMjesxd1cXkM='
            RecordData = '2 200100107B1A74DF365639CC39F1D578 AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D '
        }
        @{
            Message    = 'EAIAhCABABB7GnTfNlY5zDnx1XgDAQABt3HKE25K61zkQzPFOz0sE8IiQ4Ufxwi8zin34utXh7X1bMrTT4IjrMEJBN21ay7EptYjLztQ6glPCRSzuUG75SmvWCw2u63v2vKtr5tJEZBvWyUiYDxhUnK4gOyPuTDMbuOcRE2qdbFnjwBaSySZ0dpUM/gFx6WtMjesxd1cXkMDcnZzB2V4YW1wbGUDY29tAA=='
            RecordData = '2 200100107B1A74DF365639CC39F1D578 AwEAAbdxyhNuSutc5EMzxTs9LBPCIkOFH8cIvM4p9+LrV4e19WzK00+CI6zBCQTdtWsuxKbWIy87UOoJTwkUs7lBu+Upr1gsNrut79ryra+bSRGQb1slImA8YVJyuIDsj7kwzG7jnERNqnWxZ48AWkskmdHaVDP4BcelrTI3rMXdXF5D rvs.example.com.'
        }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsHIPRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
