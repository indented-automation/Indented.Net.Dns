class DnsAAAARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    ADDRESS                    |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [IPAddress] $IPAddress

    DnsAAAARecord() : base() { }
    DnsAAAARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.IPAddress = $binaryReader.ReadIPv6Address()
    }

    hidden [string] RecordDataToString() {
        return $this.IPAddress.IPAddressToString
    }
}
