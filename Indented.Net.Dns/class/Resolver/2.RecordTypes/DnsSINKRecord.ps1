class DnsSINKRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        CODING         |       SUBCODING       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     DATA                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/id/draft-eastlake-kitchen-sink-02.txt
    #>

    [RecordType] $RecordType = [RecordType]::SINK
    [Byte]       $Coding
    [Byte]       $Subcoding
    [String]     $Data

    DnsSINKRecord() : base() { }
    DnsSINKRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Coding = $binaryReader.ReadByte()
        $this.Subcoding = $binaryReader.ReadByte()

        $dataLength = $this.RecordDataLength - 2
        if ($dataLength -gt 0) {
            $this.Data = $binaryReader.ReadBytes($dataLength)
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2}' -f @(
            [Byte]$this.Coding
            [Byte]$this.Subcoding
            [String]$this.Data
        )
    }
}