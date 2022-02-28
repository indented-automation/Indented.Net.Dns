Describe DnsHeader {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }

        $headerFlags = InModuleScope @module { [HeaderFlags] }
    }

    Context 'EndianBinaryReader constructor' {
        It 'Parses <RCode> correctly' -TestCases @(
            @{ RCode = 'NoError';  Message = 'AAKBgAABAAYAAAAA'; ExpectedFlags = 'RA, RD' }
            @{ RCode = 'NXDomain'; Message = 'AAOBgwABAAAAAQAA'; ExpectedFlags = 'RA, RD' }
        ) {
            $header = InModuleScope -Parameters @{ Message = $Message } @module {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                [DnsHeader]::new($binaryReader)
            }

            $header.Flags | Should -Be $ExpectedFlags
            $header.RCode | Should -Be $RCode
        }
    }

    Context 'Question header constructor' {
        It 'When recursion is desired' {
            $header = InModuleScope @module {
                [DnsHeader]::new($true, 1)
            }

            $header.QuestionCount | Should -Be 1
            $header.Flags -band $headerFlags::RD | Should -Be ($headerFlags::RD)
            $header.ToByteArray() | Select-Object -Skip 2 | Should -Be @(1, 0, 0, 1, 0, 0, 0, 0, 0, 0)
            $header.ToString() | Should -Match '^ID: \d+ OpCode: QUERY RCode: NOERROR Flags: RD Query: 1 Answer: 0 Authority: 0 Additional: 0$'
        }

        It 'When recursion is not desired' {
            $header = InModuleScope @module {
                [DnsHeader]::new($false, 1)
            }

            $header.QuestionCount | Should -Be 1
            $header.Flags -band $headerFlags::RD | Should -Be 0
            $header.ToByteArray() | Select-Object -Skip 2 | Should -Be @(0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
            $header.ToString() | Should -Match '^ID: \d+ OpCode: QUERY RCode: NOERROR Flags: NONE Query: 1 Answer: 0 Authority: 0 Additional: 0$'
        }
    }
}
