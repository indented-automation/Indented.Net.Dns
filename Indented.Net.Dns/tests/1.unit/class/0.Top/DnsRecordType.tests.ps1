Describe DnsRecordType {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Can cast from a <Type> with value <Value>' -TestCases @(
        @{ Type = 'String';      Value = 'A' }
        @{ Type = 'String';      Value = 'a' }
        @{ Type = 'Int32';       Value = 1 }
        @{ Type = 'UInt16';      Value = [ushort]1 }
        @{ Type = 'RecordType';  Value = [RecordType]::A }
    ) {
        $dnsRecordType = InModuleScope @module -Parameter @{ Value = $Value } {
            [DnsRecordType]$Value
        }

        $dnsRecordType.Name | Should -Be 'A'
        $dnsRecordType.TypeID | Should -Be 1
    }

    It 'Handles conversion of NSAPPTR to the name NSAP-PTR' {
        $dnsRecordType = InModuleScope @module {
            [DnsRecordType]'NSAPPTR'
        }

        $dnsRecordType.Name | Should -Be 'NSAP-PTR'
        $dnsRecordType.TypeID | Should -Be 23
    }

    It 'Handles conversion of NSAP-PTR to TypeID 23' {
        $dnsRecordType = InModuleScope @module {
            [DnsRecordType]'NSAP-PTR'
        }

        $dnsRecordType.Name | Should -Be 'NSAP-PTR'
        $dnsRecordType.TypeID | Should -Be 23
    }

    It 'Handles conversion of 23 to NSAP-PTR' {
        $dnsRecordType = InModuleScope @module {
            [DnsRecordType]'NSAP-PTR'
        }

        $dnsRecordType.Name | Should -Be 'NSAP-PTR'
        $dnsRecordType.TypeID | Should -Be 23
    }

    It 'Can be cast to UInt16' {
        $dnsRecordType = InModuleScope @module {
            [DnsRecordType]'A'
        }

        [ushort]$dnsRecordType | Should -Be 1
    }

    It 'Can be cast to RecordType' {
        $dnsRecordType = InModuleScope @module {
            [DnsRecordType]'A'
        }

        [RecordType]$dnsRecordType | Should -Be ([RecordType]::A)
    }

    It 'Supports IComparable' {
        $dnsRecordTypeA = InModuleScope @module {
            [DnsRecordType]'A'
        }
        $dnsRecordTypeNS = InModuleScope @module {
            [DnsRecordType]'NS'
        }

        $dnsRecordTypeA | Should -BeLessThan $dnsRecordTypeNS
        $dnsRecordTypeNS | Should -BeGreaterThan $dnsRecordTypeA
    }

    It 'Supports IEquatable' {
        $dnsRecordType1 = InModuleScope @module { [DnsRecordType]'A' }
        $dnsRecordType2 = InModuleScope @module { [DnsRecordType]'A' }
        $dnsRecordType3 = InModuleScope @module { [DnsRecordType]'NS' }

        $dnsRecordType1 -eq $dnsRecordType2 | Should -BeTrue
        $dnsRecordType1 -eq $dnsRecordType3 | Should -BeFalse
    }

    It 'Can be compared to a value from the RecordType enum' {
        $dnsRecordType = InModuleScope @module { [DnsRecordType]'A' }

        $dnsRecordType -eq [RecordType]::A | Should -BeTrue
    }
}
