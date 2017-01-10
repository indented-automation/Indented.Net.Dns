if (-not ('Indented.IO.EndianBinaryReader' -as [Type])) {
    Add-Type -TypeDefinition (Get-Content "$psscriptroot\..\source\classes\Indented.IO.BinaryReader.cs" -Raw)
}

add-type -TypeDefinition (gc C:\Development\Indented.Net.Dns\source\classes\Indented.IO.BinaryReader.cs -raw)

Describe Indented.IO.EndianBinaryReader {
    function New-BinaryReader {
        param(
            [Byte[]]$Bytes
        )

        $stream = New-Object System.IO.MemoryStream(,$Bytes)
        New-Object Indented.IO.EndianBinaryReader($stream)
    }
    [Byte[]]$basicDataSet = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

    Context 'Class definition' {
        It 'Can be created from a memory stream without error' {
            { New-BinaryReader -Bytes $basicDataSet } | Should Not Throw
        }

        $binaryReader = New-BinaryReader -Byte $basicDataSet
        It 'Has a read-only position marker property' {
            $binaryReader | Get-Member -Name Marker -MemberType Property | Should Not BeNullOrEmpty
        }

        It 'Has a method to set the position marker' {
            $binaryReader | Get-Member -Name SetMarker -MemberType Method | Should Not BeNullOrEmpty
        }

        $methods = [System.IO.BinaryReader].GetMethods() |
            Where-Object Name -like '*Int*' |
            Select-Object -ExpandProperty Name |
            Sort-Object -Unique
            
        foreach ($method in $methods) {
            It "Implements an overload to support big endian return values for $method" {
                ($binaryReader.$method.OverloadDefinitions -match 'IsBigEndian')[0] | Should Not BeNullOrEmpty
            }
        }

        It 'Implements an overloaded reader for "UInt48"' {
            @($binaryReader.ReadUInt48.OverloadDefinitions).Count | Should Be 2
        }

        It 'Implements an overloaded reader for IPAddresses' {
            @($binaryReader.ReadIPAddress.OverloadDefinitions).Count | Should Be 2
        }
    }

    Context 'Method implementation' {
        It 'Can peek without advancing the stream' {
            $binaryReader = New-BinaryReader -Byte $basicDataSet

            $binaryReader.PeekByte() | Should Be 1
            $binaryReader.PeekByte() | Should Be 1
            $binaryReader.BaseStream.Position | Should Be 0
        }

        $methods = [Indented.IO.EndianBinaryReader].GetMethods() |
            Where-Object { $_.Name -like '*Int*' -and $_.Name -notlike '*48' } |
            Select-Object -ExpandProperty Name |
            Sort-Object -Unique

        foreach ($method in $methods) {
            $type = $method -replace '^Read'
            $endElement = switch -Regex ($type) {
                '16$' { 1 }
                '32$' { 3 }
                '64$' { 7 }
            }
            [Byte[]]$bytes = $basicDataSet[0..$endElement]

            $littleEndianValue = [BitConverter]::"To$type"($bytes, 0)
            [Array]::Reverse($bytes)
            $bigEndianValue = [BitConverter]::"To$type"($bytes, 0)
    
            It "Can read little endian $type" {
                $binaryReader = New-BinaryReader -Byte $basicDataSet

                $binaryReader."Read$type"() | Should Be $littleEndianValue
                $binaryReader.BaseStream.Seek(0, 'Begin')
                $binaryReader."Read$type"($false) | Should Be $littleEndianValue
            }
            
            It "Can read big endian $type" {
                $binaryReader = New-BinaryReader -Byte $basicDataSet
                
                $binaryReader."Read$type"($true) | Should Be $bigEndianvalue
            }
        }

        [Byte[]]$bytes = $basicDataSet[0..5] + 0, 0
        $littleEndianValue = [BitConverter]::ToUInt64($bytes, 0)
        # The padding bytes (UInt48 to UInt64) must always be on the right. They are not part of the number at all.
        [Byte[]]$bytes = $basicDataSet[5..0] + 0, 0
        $bigEndianValue = [BitConverter]::ToUInt64($bytes, 0)

        It 'Can read little endian UInt48' {
            $binaryReader = New-BinaryReader -Byte $basicDataSet

            $binaryReader.ReadUInt48() | Should Be $littleEndianValue
            $binaryReader.BaseStream.Seek(0, 'Begin')
            $binaryReader.ReadUInt48($false) | Should Be $littleEndianValue
        }

        It 'Can read big endian UInt48' {
            $binaryReader = New-BinaryReader -Byte $basicDataSet

            $binaryReader.ReadUInt48($true) | Should Be $bigEndianValue
        }

        It 'Can read an IPv4 address' {
            $binaryReader = New-BinaryReader -Byte $basicDataSet
            $ipAddress = $binaryReader.ReadIPAddress()

            $ipAddress | Should BeOfType [IPAddress]
            $ipAddress.AddressFamily | Should Be 'InterNetwork'
            $ipAddress | Should Be '1.2.3.4'

            $binaryReader.BaseStream.Seek(0, 'Begin')
            $ipAddress = $binaryReader.ReadIPAddress($false)

            $ipAddress | Should BeOfType [IPAddress]
            $ipAddress.AddressFamily | Should Be 'InterNetwork'
            $ipAddress | Should Be '1.2.3.4'
        }

        It 'Can read an IPv6 address' {
            $binaryReader = New-BinaryReader -Byte $basicDataSet
            $ipAddress = $binaryReader.ReadIPAddress($true)

            $ipAddress | Should BeOfType [IPAddress]
            $ipAddress.AddressFamily | Should Be 'InterNetworkv6'
            $ipAddress | Should Be '102:304:506:708:90a:b0c:d0e:f10'
        }
    }
}