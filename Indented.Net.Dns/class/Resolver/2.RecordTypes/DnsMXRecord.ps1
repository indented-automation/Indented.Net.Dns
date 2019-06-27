class DnsMXRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   EXCHANGE                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::MX
    [UInt16]     $Preference
    [String]     $Exchange

    DnsMXRecord() : base() { }
    DnsMXRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Preference = $binaryReader.ReadUInt16($true)
        $this.Exchange = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference,
            $this.Exchange
        )
    }
}