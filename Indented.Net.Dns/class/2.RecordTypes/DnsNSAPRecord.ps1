class DnsNSAPRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      NSAP                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1706.txt
    #>

    [string] $Text
    [string] $Data

    DnsNSAPRecord() : base() { }
    DnsNSAPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Data = '0x{0}' -f @(
            [EndianBitConverter]::ToHexadecimal(
                $binaryReader.ReadBytes($this.RecordDataLength)
            )
        )
    }

    hidden [string] RecordDataToString() {
        return $this.Data
    }
}
