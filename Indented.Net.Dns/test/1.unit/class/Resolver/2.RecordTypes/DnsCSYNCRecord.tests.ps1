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
    Describe DnsCSYNCRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message    = 'AAAAAAAAAARgAAAI'; RecordData = '0 0 A NS AAAA' }
            @{ Message    = 'AAAAAAAA';         RecordData = '0 0' }
            @{ Message    = 'AAAAAAAAgAFA';     RecordData = '0 0 DLV' }
            @{ Message    = 'AAAAAAAAAAEggAFA'; RecordData = '0 0 NS DLV' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsCSYNCRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}