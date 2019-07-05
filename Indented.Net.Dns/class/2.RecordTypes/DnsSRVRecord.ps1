
class DnsSRVRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   PRIORITY                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    WEIGHT                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     PORT                      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    TARGET                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2782.txt
    #>

    [UInt16] $Priority
    [UInt16] $Weight
    [UInt16] $Port
    [String] $Hostname

    DnsSRVRecord() : base() { }
    DnsSRVRecord(
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
        $this.Port = $binaryReader.ReadUInt16($true)
        $this.Hostname = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3}' -f @(
            $this.Priority
            $this.Weight
            $this.Port
            $this.Hostname
        )
    }
}