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
    Describe DnsTALINKRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAd0YWxpbmsxBHRlc3QIaW5kZW50ZWQCY28CdWsA';                                         RecordData = '. talink1.test.indented.co.uk.' }
            @{ Message = 'B3RhbGluazAEdGVzdAhpbmRlbnRlZAJjbwJ1awAHdGFsaW5rMgR0ZXN0CGluZGVudGVkAmNvAnVrAA=='; RecordData = 'talink0.test.indented.co.uk. talink2.test.indented.co.uk.' }
            @{ Message = 'B3RhbGluazIEdGVzdAhpbmRlbnRlZAJjbwJ1awAA';                                         RecordData = 'talink2.test.indented.co.uk. .' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsTALINKRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}