class DnsAPLRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 ADDRESSFAMILY                 |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        PREFIX         | N|     AFDLENGTH      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    AFDPART                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/html/rfc3123
    #>

    [PSObject[]] $List

    DnsAPLRecord() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        if ($this.RecordDataLength -gt 0) {
            $listLength = $this.RecordDataLength

            $this.List = while ($listLength -gt 0) {
                $addressFamily = [IanaAddressFamily]$binaryReader.ReadUInt16($true)
                $negationAndLength = $binaryReader.ReadByte()

                $item = [PSCustomObject]@{
                    AddressFamily = $addressFamily
                    Prefix        = $BinaryReader.ReadByte()
                    Negation      = [Boolean]($negationAndLength -band 0x0800)
                    AddressLength = $negationAndLength -band 0x007F
                    Address       = $null
                }

                $addressLength = [Math]::Ceiling($item.AddressLength / 8)
                $addressBytes = switch ($item.AddressFamily) {
                    'IPv4' { [Byte[]]::new(4) }
                    'IPv6' { [Byte[]]::new(16) }
                }
                [Array]::Copy(
                    $binaryReader.ReadBytes($addressLength),
                    0,
                    $addressBytes,
                    $addressBytes.Length - $addressLength,
                    $addressLength
                )
                # Property: Address
                $item.Address = [IPAddress]::new($addressBytes)

                $item

                $listLength -= 3 + $addressLength
            }
        }
    }

    [String] RecordDataToString() {
        $values = foreach ($item in $this.List) {
            '{0}{1}:{2}/{3}' -f ('', '!')[$item.Negation],
                                [UInt16]$item.AddressFamily,
                                $item.Address,
                                $item.Prefix
        }
        if ($values.Count -gt 1) {
            return "( $values )"
        } else {
            return $values
        }
    }
}