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
    Describe DnsNSRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'A25zMQZkb21haW4HZXhhbXBsZQA='; RecordData = 'ns1.domain.example.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsNSRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}