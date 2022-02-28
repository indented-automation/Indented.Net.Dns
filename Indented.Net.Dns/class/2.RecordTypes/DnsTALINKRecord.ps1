class DnsTALINKRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     PREV                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     NEXT                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://www.iana.org/assignments/dns-parameters/TALINK/talink-completed-template
    #>

    [string] $Previous
    [string] $Next

    DnsTALINKRecord() : base() { }
    DnsTALINKRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Previous = $binaryReader.ReadDnsDomainName()
        $this.Next = $binaryReader.ReadDnsDomainName()
    }

    hidden [string] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Previous
            $this.Next
        )
    }
}
