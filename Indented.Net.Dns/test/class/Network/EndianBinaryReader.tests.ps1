InModuleScope Indented.Net.Dns {
    Describe EndianBinaryReader {
        Context ReadDnsDomainName {
            It 'Reads a single label' {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Byte[]](3, 97, 98, 99, 0)

                $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
            }

            It 'Reads multiple labels' {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Byte[]](3, 97, 98, 99, 3, 100, 101, 102, 0)

                $binaryReader.ReadDnsDomainName() | Should -Be 'abc.def.'
            }

            It 'Follows DNS message compression flags and returns to the original stream position' {
                $binaryReader = [EndianBinaryReader][System.IO.MemoryStream][Byte[]](3, 97, 98, 99, 0, 192, 0, 255)

                $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
                $binaryReader.BaseStream.Position | Should -Be 5
                $binaryReader.ReadDnsDomainName() | Should -Be 'abc.'
                $binaryReader.BaseStream.Position | Should -Be 7
                $binaryReader.ReadByte() | Should -Be 255
            }
        }

        Describe GetDnsDomainNameBytes {
            It 'Returns a single byte array' {
                [EndianBinaryReader]::GetDnsDomainNameBytes('a').GetType() | Should -Be ([Byte[]])
            }

            It 'Trims trailing periods' {
                [EndianBinaryReader]::GetDnsDomainNameBytes('a.') | Should -Be 1, 97, 0
            }

            It 'Pads names with a length byte set to 0' {
                [EndianBinaryReader]::GetDnsDomainNameBytes('') | Should -Be 0
                [EndianBinaryReader]::GetDnsDomainNameBytes('ab') | Should -Be 2, 97, 98, 0
            }
        }
    }
}