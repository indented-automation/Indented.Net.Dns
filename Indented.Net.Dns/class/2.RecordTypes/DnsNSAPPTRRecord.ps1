class DnsNSAPPTRRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     OWNER                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1348.txt
    #>

    [string] $Owner

    DnsNSAPPTRRecord() : base() { }
    DnsNSAPPTRRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Owner = $binaryReader.ReadDnsDomainName()
    }

    hidden [string] RecordDataToString() {
        return $this.Owner
    }

    [string] ToString() {
        return '{0,-29} {1,-10} {2,-5} {3,-10} {4}' -f @(
            $this.Name
            $this.TTL
            $this.RecordClass
            'NSAP-PTR'
            $this.RecordData
        )
    }
}
