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
    Describe DnsRecordType {
        It 'Can cast from a <Type> with value <Value>' -TestCases @(
            @{ Type = 'String';      Value = 'A' }
            @{ Type = 'String';      Value = 'a' }
            @{ Type = 'Int32';       Value = 1 }
            @{ Type = 'UInt16';      Value = [UInt16]1 }
            @{ Type = 'RecordType';  Value = [RecordType]::A }
        ) {
            param (
                $Type,
                $Value
            )

            $dnsRecordType = [DnsRecordType]$Value

            $dnsRecordType.Name | Should -Be 'A'
            $dnsRecordType.TypeID | Should -Be 1
        }

        It 'Handles conversion of NSAPPTR to the name NSAP-PTR' {
            $dnsRecordType = [DnsRecordType]'NSAPPTR'

            $dnsRecordType.Name | Should -Be 'NSAP-PTR'
            $dnsRecordType.TypeID | Should -Be 23
        }

        It 'Handles conversion of NSAP-PTR to TypeID 23' {
            $dnsRecordType = [DnsRecordType]'NSAP-PTR'

            $dnsRecordType.Name | Should -Be 'NSAP-PTR'
            $dnsRecordType.TypeID | Should -Be 23
        }

        It 'Handles conversion of 23 to NSAP-PTR' {
            $dnsRecordType = [DnsRecordType]'NSAP-PTR'

            $dnsRecordType.Name | Should -Be 'NSAP-PTR'
            $dnsRecordType.TypeID | Should -Be 23
        }

        It 'Can be cast to UInt16' {
            $dnsRecordType = [DnsRecordType]'A'

            [UInt16]$dnsRecordType | Should -Be 1
        }

        It 'Can be cast to RecordType' {
            $dnsRecordType = [DnsRecordType]'A'

            [RecordType]$dnsRecordType | Should -Be ([RecordType]::A)
        }

        It 'Supports IComparable' {
            $dnsRecordTypeA = [DnsRecordType]'A'
            $dnsRecordTypeNS = [DnsRecordType]'NS'

            $dnsRecordTypeA | Should -BeLessThan $dnsRecordTypeNS
            $dnsRecordTypeNS | Should -BeGreaterThan $dnsRecordTypeA
        }

        It 'Supports IEquatable' {
            $dnsRecordType1 = [DnsRecordType]'A'
            $dnsRecordType2 = [DnsRecordType]'A'
            $dnsRecordType3 = [DnsRecordType]'NS'

            $dnsRecordType1 -eq $dnsRecordType2 | Should -BeTrue
            $dnsRecordType1 -eq $dnsRecordType3 | Should -BeFalse
        }

        It 'Can be compared to a value from the RecordType enum' {
            $dnsRecordType = [DnsRecordType]'A'

            $dnsRecordType -eq [RecordType]::A | Should -BeTrue
        }
    }
}