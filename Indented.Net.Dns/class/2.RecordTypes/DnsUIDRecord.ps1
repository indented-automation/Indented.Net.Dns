class DnsUIDRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      UID                      /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        IANA-Reserved
    #>

    [byte[]] $Data

    DnsUIDRecord() : base() { }
    DnsUIDRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Data = $binaryReader.ReadBytes($this.RecordDataLength)
    }

    hidden [string] RecordDataToString() {
        return '\# {0} {1}' -f @(
            $this.Data.Length
            [EndianBitConverter]::ToHexadecimal($this.Data)
        )
    }
}
