class DnsUnknownRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  <anything>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [RecordType] $RecordType = [RecordType]::UNKNOWN
    [Byte[]]     $BinaryData

    DnsUnknownRecord() : base() { }
    DnsUnknownRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.BinaryData = $binaryReader.ReadBytes($this.RecordDataLength)
    }

    Hidden [String] RecordDataToString() {
        return [Convert]::ToBase64String($this.BinaryData)
    }
}