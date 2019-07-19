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
    Describe EndianBitConverter {
        Context GetBytes {
            It 'When the value is big-endian 16-bit integer' {
                [EndianBitConverter]::GetBytes([UInt16]258, $true) | Should -Be @(1, 2)
            }

            It 'When the value is little-endian 16-bit integer' {
                [EndianBitConverter]::GetBytes([UInt16]513, $false) | Should -Be @(1, 2)
            }

            It 'When the value is big-endian 32-bit integer' {
                [EndianBitConverter]::GetBytes([UInt32]16909060, $true) | Should -Be @(1, 2, 3, 4)
            }

            It 'When the value is little-endian 32-bit integer' {
                [EndianBitConverter]::GetBytes([UInt32]67305985, $false) | Should -Be @(1, 2, 3, 4)
            }
        }

        Context ToBinary {
            It 'Converts the byte array <Bytes> to the string <String>' -TestCases @(
                @{ Bytes = 1;      String = '00000001' }
                @{ Bytes = 255;    String = '11111111' }
                @{ Bytes = 1, 255; String = '0000000111111111' }
            ) {
                param (
                    [Byte[]]$Bytes,

                    [String]$String
                )

                [EndianBitConverter]::ToBinary($Bytes) | Should -Be $String
            }
        }

        Context ToHexadecimal {
            It 'Converts the byte array <Bytes> to the string <String>' -TestCases @(
                @{ Bytes = 1;      String = '01' }
                @{ Bytes = 255;    String = 'FF' }
                @{ Bytes = 1, 255; String = '01FF' }
            ) {
                param (
                    [Byte[]]$Bytes,

                    [String]$String
                )

                [EndianBitConverter]::ToHexadecimal($Bytes) | Should -Be $String
            }
        }

        Context ToBase32String {
            It 'Converts a byte sequence to a base32 encoded string' {
                [EndianBitConverter]::ToBase32String([Byte[]][Char[]]'hello world') | Should -Be 'D1IMOR3F41RMUSJCC4'
            }
        }
    }
}