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
            BeforeAll {
                $testCases = @(
                    @{ RecordType = 'TXT'; Message = 'CGluZGVudGVkAmNvAnVrAAAQAAE=' }
                )
            }

            It 'Parses a question containing a <RecordType> record' -TestCases $testCases {
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

            It 'ToByteArray returns the input value for a <RecordType> record' -TestCases $testCases {
                param (
                    $RecordType,
                    $RecordClass = 'IN',
                    $Message
                )

                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)
                $question = [DnsQuestion]::new($binaryReader)

                [Convert]::ToBase64String($question.ToByteArray()) | Should -Be $Message
            }
        }
    }
}
