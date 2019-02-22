param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf('\test'))
    Import-Module $moduleBase -Force
}

InModuleScope Indented.Net.Dns {
    Describe DnsQuestion {
        Context Query {
            It 'Creates a question containing specific name, type, and class' {
                $question = [DnsQuestion]::new(
                    'dns.name.',
                    'A',
                    'IN'
                )

                $question.Name | Should -Be 'dns.name.'
                $question.RecordType | Should -Be A
                $question.RecordClass | Should -Be IN
            }
        }

        Context ResponseParser {
            It 'Parses a question containing a <RecordType>' -TestCases @(
                @{ RecordType = 'TXT'; Message = 'CGluZGVudGVkAmNvAnVrAAAQAAE=' }
            ) {
                param (
                    $RecordType,
                    $RecordClass = 'IN',
                    $Message
                )

                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                $question = [DnsQuestion]::new($binaryReader)

                $question.Name | Should -Not -BeNullOrEmpty
                $question.RecordType | Should -Be $RecordType
                $question.RecordClass | Should -Be $RecordClass
            }
        }
    }
}
