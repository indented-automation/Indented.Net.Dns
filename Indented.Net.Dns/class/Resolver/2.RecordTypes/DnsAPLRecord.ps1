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

    [RecordType] $RecordType = [RecordType]::APL
    [PSObject[]] $List

    DnsAPLRecord() : base() { }
    DnsAPLRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        if ($this.RecordDataLength -gt 0) {
            $listLength = $this.RecordDataLength

            $this.List = while ($listLength -gt 0) {
                $addressFamily = [IanaAddressFamily]$binaryReader.ReadUInt16($true)
                $prefix = $binaryReader.ReadByte()
                $negationAndLength = $binaryReader.ReadByte()

                $item = [PSCustomObject]@{
                    AddressFamily = $addressFamily
                    Prefix        = $prefix
                    Negation      = [Boolean]($negationAndLength -band 0x80)
                    AddressLength = $negationAndLength -band 0x7F
                    Address       = $null
                }
                $addressBytes = switch ($item.AddressFamily) {
                    'IPv4' { [Byte[]]::new(4) }
                    'IPv6' { [Byte[]]::new(16) }
                }

                [Array]::Copy(
                    $binaryReader.ReadBytes($item.AddressLength),
                    0,
                    $addressBytes,
                    0,
                    $item.AddressLength
                )
                $item.Address = [IPAddress]::new($addressBytes)

                $item

                $listLength -= 4 + $item.AddressLength
            }
        }
    }

    hidden [String] RecordDataToString() {
        $values = foreach ($item in $this.List) {
            '{0}{1}:{2}/{3}' -f @(
                ('', '!')[$item.Negation]
                [UInt16]$item.AddressFamily
                $item.Address
                $item.Prefix
            )
        }
        return $values -join ' '
    }
}