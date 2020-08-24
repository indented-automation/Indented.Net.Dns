InModuleScope Indented.Net.Dns {
    Describe DnsHINFORecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'EEdlbmVyaWMgUEMgY2xvbmUKTmV0QlNELTEuNA=='; RecordData = '"Generic PC clone" "NetBSD-1.4"' }
            @{ Message = 'AlBDCldpbmRvd3MgMTA=';                     RecordData = '"PC" "Windows 10"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsHINFORecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}
