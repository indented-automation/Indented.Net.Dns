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
    Describe DnsA6Record {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AP////////////////////8GZG9tYWluBG5hbWUA'; RecordData = '0 ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff domain.name.' }
            @{ Message = 'QP//////////BmRvbWFpbgRuYW1lAA==';         RecordData = '64 ::ffff:ffff:ffff:ffff domain.name.' }
            @{ Message = 'fwEGZG9tYWluBG5hbWUA';                     RecordData = '127 ::1 domain.name.' }
            @{ Message = 'gAZkb21haW4EbmFtZQA=';                     RecordData = '128 domain.name.' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsA6Record]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}