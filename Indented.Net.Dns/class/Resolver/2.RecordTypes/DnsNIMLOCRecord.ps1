class DnsNIMLOCRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  BinaryData                   /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://ana-3.lcs.mit.edu/~jnc/nimrod/dns.txt
    #>

    [RecordType] $RecordType = [RecordType]::NIMLOC
    [Byte[]]     $BinaryData

    DnsNIMLOCRecord() : base() { }
    DnsNIMLOCRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.BinaryData = $binaryReader.ReadBytes($this.RecordDataLength)
    }

    hidden [String] RecordDataToString() {
        return [EndianBitConverter]::ToHexadecimal($this.BinaryData)
    }
}
