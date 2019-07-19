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
    Describe DnsHeader {
        Context 'EndianBinaryReader constructor' {
            It 'Parses <RCode> correctly' -TestCases @(
                @{ RCode = 'NoError';  Message = 'AAKBgAABAAYAAAAA'; ExpectedFlags = 'RA, RD' }
                @{ RCode = 'NXDomain'; Message = 'AAOBgwABAAAAAQAA'; ExpectedFlags = 'RA, RD' }
            ) {
                param (
                    $RCode,
                    $Message,
                    $ExpectedFlags
                )

                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Convert]::FromBase64String($Message)

                $header = [DnsHeader]::new($binaryReader)
                $header.Flags | Should -Be $ExpectedFlags
                $header.RCode | Should -Be $RCode
            }
        }

        Context 'Question header constructor' {
            It 'When recursion is desired' {
                $header = [DnsHeader]::new($true, 1)

                $header.QuestionCount | Should -Be 1
                $header.Flags -band [HeaderFlags]::RD | Should -Be ([HeaderFlags]::RD)
                $header.ToByteArray() | Select-Object -Skip 2 | Should -Be @(1, 0, 0, 1, 0, 0, 0, 0, 0, 0)
                $header.ToString() | Should -Match '^ID: \d+ OpCode: QUERY RCode: NOERROR Flags: RD Query: 1 Answer: 0 Authority: 0 Additional: 0$'
            }

            It 'When recursion is not desired' {
                $header = [DnsHeader]::new($false, 1)

                $header.QuestionCount | Should -Be 1
                $header.Flags -band [HeaderFlags]::RD | Should -Be 0
                $header.ToByteArray() | Select-Object -Skip 2 | Should -Be @(0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
                $header.ToString() | Should -Match '^ID: \d+ OpCode: QUERY RCode: NOERROR Flags: NONE Query: 1 Answer: 0 Authority: 0 Additional: 0$'
            }
        }
    }
}