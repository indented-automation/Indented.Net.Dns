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
    Describe DnsZONEMDRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{
                Message    = 'eFfPnAEAwiC4pu1XKKlxkC9+PU/ZOt7qiLBFPC6OjIY9RlqwbPNOuVsmY5jJi1kST6I5y37r'
                RecordData = '2019020700 1 0 C220B8A6ED5728A971902F7E3D4FD93ADEEA88B0453C2E8E8C863D46 5AB06CF34EB95B266398C98B59124FA239CB7EEB'
            }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsZONEMDRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}