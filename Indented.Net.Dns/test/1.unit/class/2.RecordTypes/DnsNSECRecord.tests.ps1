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
    Describe DnsNSECRecord {
        It 'Parses <RecordData>' -TestCases @(
            @{ Message = 'AWEGc2VjdXJlA25pbAAAByIBAAQAA4A='; RecordData = 'a.secure.nil. NS SOA MX LOC RRSIG NSEC DNSKEY' }
            @{ Message = 'AAAGAAABAAAB';                     RecordData = '. NSAP-PTR NSEC' }
            @{ Message = 'AAABQA==';                         RecordData = '. A' }
            @{ Message = 'AAAQAAAAAAAAAAAAAAAAAAAAAQ==';     RecordData = '. TYPE127' }
        ) {
            param (
                $Message,
                $RecordData
            )

            $recordDataBytes = [Convert]::FromBase64String($Message)
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream]$recordDataBytes
            $resourceRecord = [DnsNSECRecord]::new()
            $resourceRecord.RecordDataLength = $recordDataBytes.Count
            $resourceRecord.ReadRecordData($binaryReader)

            $resourceRecord.RecordDataToString() | Should -Be $RecordData
        }
    }
}