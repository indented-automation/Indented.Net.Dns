class DnsISDNRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                ISDNADDRESS                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                 SUBADDRESS                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1183.txt
    #>

    [String]     $ISDNAddress
    [String]     $SubAddress

    DnsISDNRecord() : base() { }
    DnsISDNRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $length = 0
        $this.ISDNAddress = $binaryReader.ReadDnsCharacterString([Ref]$length)

        if ($this.RecordDataLength - $length -gt 0) {
            $this.SubAddress = $binaryReader.ReadDnsCharacterString()
        }
    }

    hidden [String] RecordDataToString() {
        if ($this.SubAddress) {
            return '"{0}" "{1}"' -f @(
                $this.ISDNAddress
                $this.SubAddress
            )
        } else {
            return '"{0}"' -f @(
                $this.ISDNAddress
            )
        }
    }
}