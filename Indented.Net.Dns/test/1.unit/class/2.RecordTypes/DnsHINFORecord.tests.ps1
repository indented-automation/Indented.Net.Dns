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
    Describe DnsHINFORecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'EEdlbmVyaWMgUEMgY2xvbmUKTmV0QlNELTEuNA=='; RecordData = '"Generic PC clone" "NetBSD-1.4"' }
            @{ Message = 'AlBDCldpbmRvd3MgMTA=';                     RecordData = '"PC" "Windows 10"' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsHINFORecord]::new()
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}