Describe DnsResourceRecord {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        $RecordData = @{
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
        $dnsResourceRecord = InModuleScope -Parameters @{ Type = $Type; RecordData = $RecordData } @module {
            [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($RecordData[$Type]['Message'])
            )
        }

        $dnsResourceRecord.RecordType | Should -Be $Type
        $dnsResourceRecord.ToString() | Should -Be $RecordData[$Type]['RecordData']
    }

    It 'Can parse a <Type> resource record from a binary reader' -TestCases @(
        @{ Type = 'A' }
        @{ Type = 'NS' }
    ) {
        $dnsResourceRecord = InModuleScope -Parameters @{ Type = $Type; RecordData = $RecordData } @module {
            $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($RecordData[$Type]['Message'])
            [DnsResourceRecord]::Parse($binaryReader)
        }

        $dnsResourceRecord.RecordType | Should -Be $Type
        $dnsResourceRecord.ToString() | Should -Be $RecordData[$Type]['RecordData']
    }

    It 'Supports IEquatable' {
        $dnsRecordType1, $dnsRecordType2, $dnsRecordType3 = InModuleScope -Parameters @{ RecordData = $RecordData } @module {
            [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($RecordData['A']['Message'])
            )
            [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($RecordData['A']['Message'])
            )
            [DnsResourceRecord]::Parse(
                [Convert]::FromBase64String($RecordData['NS']['Message'])
            )
        }

        $dnsRecordType1 -eq $dnsRecordType2 | Should -BeTrue
        $dnsRecordTypeA -eq $dnsRecordType3 | Should -BeFalse
    }
}
