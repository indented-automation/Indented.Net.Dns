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
    Describe DnsGPOSRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAAA';                             RecordData = '"" "" ""' }
            @{ Message = 'CC0yMi42ODgyCDExNi44NjUyBTI1MC4w'; RecordData = '"-22.6882" "116.8652" "250.0"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsGPOSRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}