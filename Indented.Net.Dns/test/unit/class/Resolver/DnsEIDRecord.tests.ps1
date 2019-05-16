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
    Describe DnsEIDRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'MTI4OUFC';     RecordData = '1289AB' }
            @{ Message = 'QUFCQkND';     RecordData = 'AABBCC' }
            @{ Message = 'MTIgODkgQUI='; RecordData = '12 89 AB' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsEIDRecord]::new()
            $resourceRecord.RecordDataLength = $RecordData.Length
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}