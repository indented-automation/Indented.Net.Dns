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
    Describe DnsCAARecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AAVpc3N1ZWNhLmV4YW1wbGUubmV0OyBwb2xpY3k9ZXY='; RecordData = '0 issue "ca.example.net; policy=ev"' }
            @{ Message = 'gAN0YnNVbmtub3du';                             RecordData = '128 tbs "Unknown"' }
            @{ Message = 'gAN0YnM=';                                     RecordData = '128 tbs ""' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsCAARecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }

        It 'Self test' {
            $describeName = & (Get-Module Pester) { $pester.CurrentTestGroup.Name }


        }
    }
}