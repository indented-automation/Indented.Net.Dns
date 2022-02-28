Describe DnsQuestion {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    Context Query {
        It 'Creates a question containing specific name, type, and class' {
            $question = InModuleScope @module {
                [DnsQuestion]::new(
                    'dns.name.',
                    'A',
                    'IN'
                )
            }

            $question.Name | Should -Be 'dns.name.'
            $question.RecordType | Should -Be A
            $question.RecordClass | Should -Be IN
        }
    }

    Context ResponseParser {
        BeforeAll {
            $testCases = @(
                @{ RecordType = 'TXT'; RecordClass = 'IN'; Message = 'CGluZGVudGVkAmNvAnVrAAAQAAE=' }
            )
        }

        It 'Parses a question containing a <RecordType> record' -TestCases $testCases {
            $question = InModuleScope -Parameters @{ Message = $Message } @module {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                [DnsQuestion]::new($binaryReader)
            }

            $question.Name | Should -Not -BeNullOrEmpty
            $question.RecordType | Should -Be $RecordType
            $question.RecordClass | Should -Be $RecordClass
        }

        It 'ToByteArray returns the input value for a <RecordType> record' -TestCases $testCases {
            $question = InModuleScope -Parameters @{ Message = $Message } @module {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                [DnsQuestion]::new($binaryReader)
            }

            [Convert]::ToBase64String($question.ToByteArray()) | Should -Be $Message
        }
    }
}
