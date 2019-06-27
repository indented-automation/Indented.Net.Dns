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

    [RecordType] $RecordType = [RecordType]::NSAPPTR
    [String]     $Owner

    DnsNSAPPTRRecord() : base() { }
    DnsNSAPPTRRecord(
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

    [String] ToString() {
        return '{0} {1} {2} {3} {4}' -f @(
            $this.Name.PadRight(29, ' ')
            $this.TTL.ToString().PadRight(10, ' ')
            $this.RecordClass.ToString().PadRight(5, ' ')
            'NSAP-PTR'.PadRight(10, ' ')
            $this.RecordDataToString()
        )
    }
}