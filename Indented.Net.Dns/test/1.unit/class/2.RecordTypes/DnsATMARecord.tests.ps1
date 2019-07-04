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
    Describe DnsATMARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'ATYxMjAwMDAwMDAw'; RecordData = '+61200000000' }
            @{ Message = 'ATYxMjAwMDAwMDAw'; RecordData = '+61200000000' }
            @{ Message = 'ABI0VniQq83v';     RecordData = '1234567890abcdef' }
            @{ Message = 'AP7cugmHZUMh';     RecordData = 'fedcba0987654321' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsATMARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}