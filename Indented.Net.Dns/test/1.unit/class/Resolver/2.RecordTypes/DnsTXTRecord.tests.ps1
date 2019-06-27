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
    Describe DnsTXTRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'C0hlbGxvIHdvcmxk';                                     RecordData = '"Hello world"' }
            @{ Message = 'JnY9c3BmMSBpbmNsdWRlOnNwZi5kb21haW4uZXhhbXBsZSB+YWxs'; RecordData = '"v=spf1 include:spf.domain.example ~all"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsTXTRecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}