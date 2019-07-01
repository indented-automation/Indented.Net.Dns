class DnsCAARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |         FLAGS         |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                      TAG                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     VALUE                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/html/rfc6844
    #>

    [RecordType] $RecordType = [RecordType]::CAA
    [CAAFlag]    $CAAFlag
    [String]     $Tag
    [String]     $Value

    DnsCAARecord() : base() { }
    DnsCAARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.CAAFlag = $binaryReader.ReadByte()

        $length = 0
        $this.Tag = $binaryReader.ReadDnsCharacterString($length)

        $this.Value = [String]::new($binaryReader.ReadChars(
            $this.RecordDataLength - $length - 1
        ))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} "{2}"' -f @(
            [Byte]$this.CAAFlag
            $this.Tag
            $this.Value
        )
    }
}