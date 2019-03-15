class DnsDNAMERecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     TARGET                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2672.txt
    #>

    [RecordType] $RecordType = [RecordType]::DNAME
    [String]     $Target

    DnsDNAMERecord() : base() { }
    DnsDNAMERecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Target = $binaryReader.ReadDnsDomainName()
    }

    Hidden [String] RecordDataToString() {
        return $this.Target
    }
}