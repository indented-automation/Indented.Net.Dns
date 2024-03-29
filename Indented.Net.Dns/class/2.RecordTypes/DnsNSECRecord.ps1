class DnsNSECRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   DOMAINNAME                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   <BIT MAP>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [string]          $DomainName
    [DnsRecordType[]] $RRType

    DnsNSECRecord() : base() { }
    DnsNSECRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $length = 0
        $this.DomainName = $binaryReader.ReadDnsDomainName([ref]$length)

        $this.RRType = $binaryReader.ReadBitMap(
            $this.RecordDataLength - $length
        )
    }

    hidden [string] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.DomainName
            $this.RRType -join ' '
        )
    }
}
