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

        The structure above is modified to match dig. Adding a meaning byte.
    #>

    [RecordType] $RecordType = [RecordType]::SINK
    [Byte]       $Meaning
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
        $this.Meaning = $binaryReader.ReadByte()
        $this.Coding = $binaryReader.ReadByte()
        $this.Subcoding = $binaryReader.ReadByte()

        $dataLength = $this.RecordDataLength - 2
        if ($dataLength -gt 0) {
            $this.Data = [Convert]::ToBase64String($binaryReader.ReadBytes($dataLength))
        }
    }

    hidden [String] RecordDataToString() {
        if ($this.Data) {
            return '{0} {1} {2} {3}' -f @(
                [Byte]$this.Meaning
                [Byte]$this.Coding
                [Byte]$this.Subcoding
                [String]$this.Data
            )
        } else {
            return '{0} {1} {2}' -f @(
                [Byte]$this.Meaning
                [Byte]$this.Coding
                [Byte]$this.Subcoding
            )
        }
    }
}