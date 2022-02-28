Describe DnsHINFORecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Parses <RecordData>' -TestCases @(
        @{ Message = 'EEdlbmVyaWMgUEMgY2xvbmUKTmV0QlNELTEuNA=='; RecordData = '"Generic PC clone" "NetBSD-1.4"' }
        @{ Message = 'AlBDCldpbmRvd3MgMTA='; RecordData = '"PC" "Windows 10"' }
    ) {
        $resourceRecord = InModuleScope -Parameters @{ Message = $Message } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsHINFORecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)
            $resourceRecord
        }

        $resourceRecord.RecordDataToString() | Should -Be $RecordData
    }
}
