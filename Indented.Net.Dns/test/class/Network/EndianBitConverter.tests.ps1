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
            It 'Converts a byte array to binary' {
                [EndianBitConverter]::ToBinary(1) | Should -Be '00000001'
                [EndianBitConverter]::ToBinary(255) | Should -Be '11111111'
                [EndianBitConverter]::ToBinary((1, 255)) | Should -Be '0000000111111111'
            }
        }
    }
}