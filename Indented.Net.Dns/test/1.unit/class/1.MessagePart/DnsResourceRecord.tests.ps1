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
    Describe DnsResourceRecord {
        BeforeAll {
            $recordData = @{
                'A'  = @{
                    Message = 'A3d3dwZkb21haW4DY29tAAABAAEAAAAeAAQBAgME'
                    RecordData = 'www.domain.com.               30         IN    A          1.2.3.4'
                }
                'NS' = @{
                    Message    = 'BmRvbWFpbgNjb20AAAIAAQAAAB4AEANuczEGZG9tYWluA2NvbQA='
                    RecordData = 'domain.com.                   30         IN    NS         ns1.domain.com.'
                }
            }
        }

        It 'Can parse a <Type> resource record from a byte array' -TestCases @(
            @{ Type = 'A' }
            @{ Type = 'NS' }
        ) {
            param (
                $Type
            )

            $dnsResourceRecord = [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($recordData[$Type]['Message'])
            )

            $dnsResourceRecord.RecordType | Should -Be $Type
            $dnsResourceRecord.ToString() | Should -Be $recordData[$Type]['RecordData']
        }

        It 'Can parse a <Type> resource record from a binary reader' -TestCases @(
            @{ Type = 'A' }
            @{ Type = 'NS' }
        ) {
            param (
                $Type
            )

            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($recordData[$Type]['Message'])

            $dnsResourceRecord = [DnsResourceRecord]::Parse($binaryReader)

            $dnsResourceRecord.RecordType | Should -Be $Type
            $dnsResourceRecord.ToString() | Should -Be $recordData[$Type]['RecordData']
        }

        It 'Supports IEquatable' {
            $dnsRecordType1 = [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($recordData['A']['Message'])
            )
            $dnsRecordType2 = [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($recordData['A']['Message'])
            )
            $dnsRecordType3 = [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($recordData['NS']['Message'])
            )

            $dnsRecordType1 -eq $dnsRecordType2 | Should -BeTrue
            $dnsRecordTypeA -eq $dnsRecordType3 | Should -BeFalse
        }
    }
}