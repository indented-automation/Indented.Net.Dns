#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

InModuleScope Indented.Net.Dns {
    Describe DnsSOARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message = 'A25zMQdleGFtcGxlAApob3N0bWFzdGVyB2V4YW1wbGUAX215tQAAAAUAAAAFABuvgAAADhA='
                RecordData = @(
                    'ns1.example. hostmaster.example. ('
                    '    1601010101 ; serial'
                    '    5          ; refresh (5 seconds)'
                    '    5          ; retry (5 seconds)'
                    '    1814400    ; expire (3 weeks)'
                    '    3600       ; minimum ttl (1 hour)'
                    ')'
                ) -join "`n"
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsSOARecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}