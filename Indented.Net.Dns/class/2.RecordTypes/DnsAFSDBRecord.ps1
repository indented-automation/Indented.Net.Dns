class DnsAFSDBRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    SUBTYPE                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    HOSTNAME                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1183.txt
    #>

    [AFSDBSubType] $SubType
    [UInt16]       $SubTypeValue
    [String]       $Hostname

    DnsAFSDBRecord() : base() { }
    DnsAFSDBRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.SubTypeValue = $binaryReader.ReadUInt16($true)
        if ([Enum]::IsDefined([AFSDBSubType], [Int32]$this.SubTypeValue)) {
            $this.SubType = [Int32]$this.SubTypeValue
        }
        $this.Hostname = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.SubTypeValue
            $this.Hostname
        )
    }
}