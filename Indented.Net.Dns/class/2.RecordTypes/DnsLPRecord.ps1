class DnsLPRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     FQDN                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2230.txt
    #>

    [RecordType] $RecordType = [RecordType]::LP
    [UInt16]     $Preference
    [String]     $FQDN

    DnsLPRecord() : base() { }
    DnsLPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Preference = $binaryReader.ReadUInt16($true)
        $this.FQDN = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference
            $this.FQDN
        )
    }
}