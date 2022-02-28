Describe EndianBitConverter {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    Context GetBytes {
        It 'When the value is big-endian 16-bit integer' {
            InModuleScope @module {
                [EndianBitConverter]::GetBytes([UInt16]258, $true)
            } | Should -Be @(1, 2)
        }

        It 'When the value is little-endian 16-bit integer' {
            InModuleScope @module {
                [EndianBitConverter]::GetBytes([UInt16]513, $false)
            } | Should -Be @(1, 2)
        }

        It 'When the value is big-endian 32-bit integer' {
            InModuleScope @module {
                [EndianBitConverter]::GetBytes([UInt32]16909060, $true)
            } | Should -Be @(1, 2, 3, 4)
        }

        It 'When the value is little-endian 32-bit integer' {
            InModuleScope @module {
                [EndianBitConverter]::GetBytes([UInt32]67305985, $false)
            } | Should -Be @(1, 2, 3, 4)
        }
    }

    Context ToBinary {
        It 'Converts the byte array <Bytes> to the string <String>' -TestCases @(
            @{ Bytes = 1;      String = '00000001' }
            @{ Bytes = 255;    String = '11111111' }
            @{ Bytes = 1, 255; String = '0000000111111111' }
        ) {
            InModuleScope -Parameters @{ Bytes = $Bytes } @module {
                [EndianBitConverter]::ToBinary($Bytes)
            } | Should -Be $String
        }
    }

    Context ToHexadecimal {
        It 'Converts the byte array <Bytes> to the string <String>' -TestCases @(
            @{ Bytes = 1;      String = '01' }
            @{ Bytes = 255;    String = 'FF' }
            @{ Bytes = 1, 255; String = '01FF' }
        ) {
            InModuleScope -Parameters @{ Bytes = $Bytes } @module {
                [EndianBitConverter]::ToHexadecimal($Bytes)
            } | Should -Be $String
        }
    }

    Context ToBase32String {
        It 'Converts a byte sequence to a base32 encoded string' {
            InModuleScope @module {
                [EndianBitConverter]::ToBase32String([byte[]][Char[]]'hello world')
            } | Should -Be 'D1IMOR3F41RMUSJCC4'
        }
    }
}
