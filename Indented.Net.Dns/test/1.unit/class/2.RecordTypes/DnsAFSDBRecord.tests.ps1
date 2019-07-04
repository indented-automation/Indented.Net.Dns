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
    Describe DnsAFSDBRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAEGZG9tYWluBG5hbWUA'; RecordData = '1 domain.name.' }
            @{ Message = 'AAIGZG9tYWluBG5hbWUA'; RecordData = '2 domain.name.' }
            @{ Message = '//8GZG9tYWluBG5hbWUA'; RecordData = '65535 domain.name.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsAFSDBRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}