class DnsNAPTRRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     ORDER                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   PREFERENCE                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     FLAGS                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   SERVICES                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    REGEXP                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  REPLACEMENT                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2915.txt
    #>

    [UInt16] $Order
    [UInt16] $Preference
    [String] $Flags
    [String] $Service
    [String] $RegularExpression
    [String] $Replacement

    DnsNAPTRRecord() : base() { }
    DnsNAPTRRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Order = $binaryReader.ReadUInt16($true)
        $this.Preference = $binaryReader.ReadUInt16($true)
        $this.Flags = $binaryReader.ReadDnsCharacterString()
        $this.Service = $binaryReader.ReadDnsCharacterString()
        $this.RegularExpression = $binaryReader.ReadDnsCharacterString()
        $this.Replacement = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} "{2}" "{3}" "{4}" {5}' -f @(
            $this.Order
            $this.Preference
            $this.Flags
            $this.Service
            $this.RegularExpression
            $this.Replacement
        )
    }
}
