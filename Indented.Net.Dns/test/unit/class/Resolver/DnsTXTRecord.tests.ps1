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
            @{ Message = 'SGVsbG8gd29ybGQ=';                                     RecordData = 'Hello world' }
            @{ Message = 'dj1zcGYxIGluY2x1ZGU6c3BmLmRvbWFpbi5leGFtcGxlIH5hbGw='; RecordData = 'v=spf1 include:spf.domain.example ~all' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
            $resourceRecord = [DnsTXTRecord]::new()
            $resourceRecord.RecordDataLength = $RecordData.Length
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}