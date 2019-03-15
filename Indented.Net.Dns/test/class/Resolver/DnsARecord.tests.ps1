param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf('\test'))
    Import-Module $moduleBase -Force
}

InModuleScope Indented.Net.Dns {
    Describe DnsARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAA=='; RecordData = '0.0.0.0' }
            @{ Message = 'wKgUHg=='; RecordData = '192.168.20.30' }
            @{ Message = '/////w=='; RecordData = '255.255.255.255' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsARecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}