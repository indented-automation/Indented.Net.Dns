class DnsPXRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   MAP822                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   MAPX400                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2163.txt
    #>

    [UInt16] $Preference
    [string] $MAP822
    [string] $MAPX400

    DnsPXRecord() : base() { }
    DnsPXRecord(
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
        $this.MAP822 = $binaryReader.ReadDnsDomainName()
        $this.MAPX400 = $binaryReader.ReadDnsDomainName()
    }

    hidden [string] RecordDataToString() {
        return '{0,-5} {1} {2}' -f @(
            $this.Preference
            $this.MAP822
            $this.MAPX400
        )
    }
}
