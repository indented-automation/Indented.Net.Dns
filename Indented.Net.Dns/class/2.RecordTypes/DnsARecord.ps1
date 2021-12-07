class DnsARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    ADDRESS                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [IPAddress] $IPAddress

    DnsARecord() : base() { }
    DnsARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.IPAddress = $binaryReader.ReadIPAddress()
    }

    hidden [string] RecordDataToString() {
        return $this.IPAddress.IPAddressToString
    }
}
