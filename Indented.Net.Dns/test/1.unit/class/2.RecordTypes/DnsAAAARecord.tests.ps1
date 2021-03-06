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
    Describe DnsAAAARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAAAAAAAAAAAAAAAAAAAQ=='; RecordData = '::1' }
            @{ Message = 'KgAUUEAJCAEAAAAAAAAgBA=='; RecordData = '2a00:1450:4009:801::2004' }
            @{ Message = '/////////////////////w=='; RecordData = 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsAAAARecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}