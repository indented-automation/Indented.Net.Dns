class DnsKXRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   EXCHANGER                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2230.txt
    #>

    [UInt16] $Preference
    [string] $Exchanger

    DnsKXRecord() : base() { }
    DnsKXRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Preference = $binaryReader.ReadUInt16($true)
        $this.Exchanger = $binaryReader.ReadDnsDomainName()
    }

    hidden [string] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference
            $this.Exchanger
        )
    }
}
