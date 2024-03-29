Describe EndianBinaryReader {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    Context ReadUInt16 {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2)
            }
        }

        It 'Reads a big-endian unsigned 16-bit integer' {
            $binaryReader.ReadUInt16($true) | Should -Be ((1 -shl 8) -bor 2)
        }

        It 'Reads a little-endian unsigned 16-bit integer' {
            $binaryReader.ReadUInt16() | Should -Be (1 -bor (2 -shl 8))
        }
    }

    Context ReadUInt32 {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2, 3, 4)
            }
        }

        It 'Reads a big-endian unsigned 32-bit integer' {
            $binaryReader.ReadUInt32($true) | Should -Be (
                (1 -shl 24) -bor
                (2 -shl 16) -bor
                (3 -shl 8) -bor
                4
            )
        }

        It 'Reads a little-endian unsigned 32-bit integer' {
            $binaryReader.ReadUInt32() | Should -Be (
                1 -bor
                (2 -shl 8) -bor
                (3 -shl 16) -bor
                (4 -shl 24)
            )
        }
    }

    Context ReadUInt48 {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2, 3, 4, 5, 6)
            }
        }

        It 'Reads a big-endian unsigned 48-bit integer' {
            $binaryReader.ReadUInt48($true) | Should -Be (
                ([UInt64]1 -shl 40) -bor
                ([UInt64]2 -shl 32) -bor
                ([UInt64]3 -shl 24) -bor
                ([UInt64]4 -shl 16) -bor
                ([UInt64]5 -shl 8) -bor
                6
            )
        }

        It 'Reads a little-endian unsigned 48-bit integer' {
            $binaryReader.ReadUInt48() | Should -Be (
                1 -bor
                ([UInt64]2 -shl 8) -bor
                ([UInt64]3 -shl 16) -bor
                ([UInt64]4 -shl 24) -bor
                ([UInt64]5 -shl 32) -bor
                ([UInt64]6 -shl 40)
            )
        }
    }

    Context ReadUInt64 {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2, 3, 4, 5, 6, 7, 8)
            }
        }

        It 'Reads a big-endian unsigned 64-bit integer' {
            $binaryReader.ReadUInt64($true) | Should -Be (
                ([UInt64]1 -shl 56) -bor
                ([UInt64]2 -shl 48) -bor
                ([UInt64]3 -shl 40) -bor
                ([UInt64]4 -shl 32) -bor
                ([UInt64]5 -shl 24) -bor
                ([UInt64]6 -shl 16) -bor
                ([UInt64]7 -shl 8) -bor
                8
            )
        }

        It 'Reads a little-endian unsigned 64-bit integer' {
            $binaryReader.ReadUInt64() | Should -Be (
                1 -bor
                ([UInt64]2 -shl 8) -bor
                ([UInt64]3 -shl 16) -bor
                ([UInt64]4 -shl 24) -bor
                ([UInt64]5 -shl 32) -bor
                ([UInt64]6 -shl 40) -bor
                ([UInt64]7 -shl 48) -bor
                ([UInt64]8 -shl 56)
            )
        }
    }

    Context PeekByte {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2)
            }
        }

        It 'Peeks without advancing the stream' {
            $binaryReader.PeekByte() | Should -Be 1
            $binaryReader.ReadByte() | Should -Be 1

            $binaryReader.PeekByte() | Should -Be 2
            $binaryReader.ReadByte() | Should -Be 2
        }
    }

    Context ReadIPAddress {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2, 3, 4)
            }
        }

        It 'Reads an IPv4 address' {
            $address = $binaryReader.ReadIPAddress()

            $address | Should -BeOfType [IPAddress]
            $address.AddressFamily | Should -Be 'InterNetwork'
            $address | Should -Be '1.2.3.4'
        }
    }

    Context ReadIPv6Address {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
            }
        }

        It 'Reads an IPv6 address' {
            $address = $binaryReader.ReadIPv6Address()

            $address | Should -BeOfType [IPAddress]
            $address.AddressFamily | Should -Be 'InterNetworkv6'
            $address | Should -Be '102:304:506:708:90a:b0c:d0e:f10'
        }
    }

    Context ReadDnsCharacterString {
        BeforeEach {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](5, 97, 98, 99, 100, 101)
            }
        }

        It 'Reads a length-prefixed string' {
            $binaryReader.ReadDnsCharacterString() | Should -Be 'abcde'
        }
    }

    Context ReadBitMap {
        It 'Reads a bitmap field describing record types starting from window 0' {
            [byte[]]$bytes = 0, 1, 80

            $binaryReader = InModuleScope -Parameter @{ bytes = $bytes } @module {
                [EndianBinaryReader][System.IO.MemoryStream]$bytes
            }

            $binaryReader.ReadBitMap($bytes.Count) | Should -Be (1, 3)
        }

        It 'Reads a bitmap field describing record types starting from window 0 to window 1' {
            [byte[]]$bytes = 0, 2, 80, 80

            $binaryReader = InModuleScope -Parameter @{ bytes = $bytes } @module {
                [EndianBinaryReader][System.IO.MemoryStream]$bytes
            }

            $binaryReader.ReadBitMap($bytes.Count) | Should -Be (1, 3, 9, 11)
        }

        It 'Reads a bitmap field describing record types starting from window 1' {
            [byte[]]$bytes = 1, 1, 80

            $binaryReader = InModuleScope -Parameter @{ bytes = $bytes } @module {
                [EndianBinaryReader][System.IO.MemoryStream]$bytes
            }

            $binaryReader.ReadBitMap($bytes.Count) | Should -Be (257, 259)
        }
    }

    Context ReadDnsDomainName {
        It 'Reads a single label' {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](3, 97, 98, 99, 0)
            }

            $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
        }

        It 'Reads multiple labels' {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](3, 97, 98, 99, 3, 100, 101, 102, 0)
            }

            $binaryReader.ReadDnsDomainName() | Should -Be 'abc.def.'
        }

        It 'Follows DNS message compression flags and returns to the original stream position' {
            $binaryReader = InModuleScope @module {
                [EndianBinaryReader][System.IO.MemoryStream][byte[]](3, 97, 98, 99, 0, 192, 0, 255)
            }

            $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
            $binaryReader.BaseStream.Position | Should -Be 5
            $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
            $binaryReader.BaseStream.Position | Should -Be 7
            $binaryReader.ReadByte() | Should -Be 255
        }
    }

    Context GetDnsDomainNameBytes {
        It 'Returns a single byte array' {
            InModuleScope @module {
                [EndianBinaryReader]::GetDnsDomainNameBytes('a').GetType()
            } | Should -Be ([byte[]])
        }

        It 'Trims trailing periods' {
            InModuleScope @module {
                [EndianBinaryReader]::GetDnsDomainNameBytes('a.')
            } | Should -Be 1, 97, 0
        }

        It 'Pads names with a length byte set to 0' {
            InModuleScope @module { [EndianBinaryReader]::GetDnsDomainNameBytes('') } | Should -Be 0
            InModuleScope @module { [EndianBinaryReader]::GetDnsDomainNameBytes('ab') } | Should -Be 2, 97, 98, 0
        }
    }
}
