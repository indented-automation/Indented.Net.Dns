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

    [RecordType] $RecordType = [RecordType]::NAPT
    [UInt16]     $Order
    [UInt16]     $Preference
    [String]     $Flags
    [String]     $Service
    [String]     $RegularExpression
    [String]     $Replacement

    DnsNAPTRRecord() : base() { }
    DnsNAPTRRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Order = $this.ReadUInt16($true)
        $this.Preference = $this.ReadUInt16($true)
        $this.Flags = $binaryReader.ReadDnsCharacterString()
        $this.Service = $binaryReader.ReadDnsCharacterString()
        $this.RegularExpression = $binaryReader.ReadDnsCharacterString()
        $this.Replacement = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        $format = @(
            ''
            '    ;;  order    pref  flags  service       regexp              replacement'
            '        {0} {1} {2} {3} {4} {5}'
        ) -join "`n"

        return $format -f @(
            $this.Order.ToString().PadRight(8, ' '),
            $this.Preference.ToString().PadRight(5, ' '),
            $this.Flags.PadRight(6, ' '),
            $this.Service.PadRight(13, ' '),
            $this.RegularExpression.PadRight(19, ' '),
            $this.Replacement
        )
    }
}
