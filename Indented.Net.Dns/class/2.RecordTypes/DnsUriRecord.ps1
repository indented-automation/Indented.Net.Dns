class DnsURIRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    PRIORITY                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     WEIGHT                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     TARGET                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://tools.ietf.org/html/rfc7553
    #>

    [RecordType] $RecordType = [RecordType]::URI
    [UInt16]     $Priority
    [UInt16]     $Weight
    [String]     $Target

    DnsURIRecord() : base() { }
    DnsURIRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Priority = $binaryReader.ReadUInt16($true)
        $this.Weight = $binaryReader.ReadUInt16($true)

        $this.Target = [String]::new($binaryReader.ReadChars(
            $this.RecordDataLength - 4
        ))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} "{2}"' -f @(
            $this.Priority
            $this.Weight
            $this.Target
        )
    }
}