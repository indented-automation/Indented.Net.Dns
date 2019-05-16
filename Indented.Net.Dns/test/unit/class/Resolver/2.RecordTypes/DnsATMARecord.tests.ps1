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
        # It 'Parses <RecordData>' -TestCases @(
        #     @{ Message = 'ACs2MTIwMDAwMDAwMA=='; RecordData = '+61200000000' }
        #     @{ Message = 'AAEghAoAAAEAARgBCg=='; RecordData = '+61.2.0000.0000' }
        #     @{ Message = 'AAEghAoAAAEAARgBCg=='; RecordData = '1234567890abcdef' }
        #     @{ Message = 'AAEghAoAAAEAARgBCg=='; RecordData = 'f.e.d.c.b.a.0.9.8.7.6.5.4.3.2.1' }
        # ) {
        #     param (
        #         $Message,
        #         $RecordData
        #     )

        #     $recordDataBytes = [Convert]::FromBase64String($Message)
        #     $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
        #     $resourceRecord = [DnsATMARecord]::new()
        #     $resourceRecord.RecordDataLength = $recordDataBytes.Count
        #     $resourceRecord.ReadRecordData($binaryReader)

        #     $resourceRecord | ConvertTo-Json | Write-Host

        #     $resourceRecord.RecordDataToString() | Should -Be $RecordData
        # }
    }
}