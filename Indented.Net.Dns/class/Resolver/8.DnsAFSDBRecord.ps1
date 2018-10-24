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

    [Object] $SubType
    [String] $Hostname

    DnsAFSDBRecord() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $subTypeValue = $binaryReader.ReadUInt16($true)
        if ([Enum]::IsDefined([AFSDBSubType], $subTypeValue)) {
            $this.SubType = [AFSDBSubType]$subTypeValue
        }
        $this.SubType = $subTypeValue
        $this.Hostname = $binaryReader.ReadDnsDomainName()
    }

    [String] RecordDataToString() {
        return '{0} {1}' -f $this.SubType,
                            $this.Hostname
    }
}