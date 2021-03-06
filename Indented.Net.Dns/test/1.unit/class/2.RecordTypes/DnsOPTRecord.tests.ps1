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
    Describe DnsOPTRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = ''; RecordData = '' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsOPTRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }

    It 'Converts to a resource record to bytes' {
        $resourceRecord = [DnsOPTRecord]@{
            MaximumPayloadSize = 4096
            Z                  = 'DO'
        }

        [Convert]::ToBase64String($resourceRecord.ToByteArray()) | Should -Be 'AAApEAAAAIAAAAA='
    }
}