InModuleScope Indented.Net.Dns {
    Describe ConvertToDnsDomainName {
        function New-BinaryReader {
            param(
                [Byte[]]$message
            )

            $stream = New-Object System.IO.MemoryStream(,$message)
            New-Object Indented.IO.EndianBinaryReader($stream)
        }

        It 'Returns a single string' {
            $binaryReader = New-BinaryReader -Message 3, 97, 98, 99, 0

            $returnValue = ConvertToDnsDomainName -BinaryReader $binaryReader
            @($returnValue).Count | Should Be 1
            $returnValue | Should BeOfType [String]
        }

        It 'Reads a single label from a byte stream' {
            $binaryReader = New-BinaryReader -Message 3, 97, 98, 99, 0

            ConvertToDnsDomainName -BinaryReader $binaryReader | Should Be 'abc.'            
        }

        It 'Always appends a period to the end of the name' {
            $binaryReader = New-BinaryReader -Message 3, 97, 98, 99, 0

            ConvertToDnsDomainName -BinaryReader $binaryReader | Should Be 'abc.'
        }

        It 'Reads multiple labels from a byte stream' {
            $binaryReader = New-BinaryReader -Message 3, 97, 98, 99, 3, 100, 101, 102, 0

            ConvertToDnsDomainName -BinaryReader $binaryReader | Should Be 'abc.def.'            
        }

        It 'Follows DNS message compression and returns to the original stream position' {
            $binaryReader = New-BinaryReader -Message 3, 97, 98, 99, 0, 192, 0, 255

            ConvertToDnsDomainName -BinaryReader $binaryReader | Should Be 'abc.'
            $binaryReader.BaseStream.Position | Should Be 5
            ConvertToDnsDomainName -BinaryReader $binaryReader | Should Be 'abc.'
            $binaryReader.BaseStream.Position | Should Be 7
            $binaryReader.ReadByte() | Should Be 255
        }
    }
}