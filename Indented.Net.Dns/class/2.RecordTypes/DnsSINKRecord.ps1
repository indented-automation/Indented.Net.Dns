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

    [byte]   $Meaning
    [byte]   $Coding
    [byte]   $Subcoding
    [string] $Data

    DnsSINKRecord() : base() { }
    DnsSINKRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Meaning = $binaryReader.ReadByte()
        $this.Coding = $binaryReader.ReadByte()
        $this.Subcoding = $binaryReader.ReadByte()

        $dataLength = $this.RecordDataLength - 3
        if ($dataLength -gt 0) {
            $this.Data = [Convert]::ToBase64String($binaryReader.ReadBytes($dataLength))
        }
    }

    hidden [string] RecordDataToString() {
        if ($this.Data) {
            return '{0:D} {1:D} {2:D} {3}' -f @(
                $this.Meaning
                $this.Coding
                $this.Subcoding
                $this.Data
            )
        } else {
            return '{0:D} {1:D} {2:D}' -f @(
                $this.Meaning
                $this.Coding
                $this.Subcoding
            )
        }
    }
}
