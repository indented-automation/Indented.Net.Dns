class DnsUINFORecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     UINFO                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        IANA-Reserved
    #>

    [RecordType] $RecordType = [RecordType]::UINFO
    [Byte[]]     $Data

    DnsUINFORecord() : base() { }
    DnsUINFORecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Data = $binaryReader.ReadBytes($this.RecordDataLength)
    }

    hidden [String] RecordDataToString() {
        return '\# {0} {1}' -f @(
            $this.Data.Length
            [EndianBitConverter]::ToHexadecimal($this.Data)
        )
    }
}