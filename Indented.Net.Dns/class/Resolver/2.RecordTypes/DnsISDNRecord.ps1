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

    [RecordType] $RecordType = [RecordType]::ISDN
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

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.ISDNAddress = $binaryReader.ReadDnsCharacterString()
        $this.SubAddress = $binaryReader.ReadDnsCharacterString()
    }

    hidden [String] RecordDataToString() {
        return '"{0}" "{1}"' -f @(
            $this.ISDNAddress,
            $this.SubAddress
        )
    }
}