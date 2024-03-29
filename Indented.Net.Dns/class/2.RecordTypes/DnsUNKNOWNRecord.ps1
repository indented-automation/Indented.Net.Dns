class DnsUNKNOWNRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  <anything>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [byte[]] $BinaryData

    DnsUNKNOWNRecord() : base() { }
    DnsUNKNOWNRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.BinaryData = $binaryReader.ReadBytes($this.RecordDataLength)
    }

    hidden [string] RecordDataToString() {
        return [Convert]::ToBase64String($this.BinaryData)
    }
}
