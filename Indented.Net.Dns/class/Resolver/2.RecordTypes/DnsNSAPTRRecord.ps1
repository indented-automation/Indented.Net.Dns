class DnsNSAPTRRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     OWNER                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1348.txt
    #>

    [RecordType] $RecordType = [RecordType]::NSAPTR
    [String]     $Owner

    DnsNSAPTRRecord() : base() { }
    DnsNSAPTRRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Owner = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return $this.Hostname
    }
}