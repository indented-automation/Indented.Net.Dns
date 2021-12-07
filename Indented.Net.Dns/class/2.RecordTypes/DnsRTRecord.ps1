class DnsRTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /               INTERMEDIATEHOST                /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+


        http://www.ietf.org/rfc/rfc1183.txt
    #>

    [ushort] $Preference
    [string] $IntermediateHost

    DnsRTRecord() : base() { }
    DnsRTRecord(
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
        $this.IntermediateHost = $binaryReader.ReadDnsDomainName()
    }

    hidden [string] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference,
            $this.IntermediateHost
        )
    }
}
