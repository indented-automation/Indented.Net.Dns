class DnsZONEMDRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    SERIAL                     |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |      DIGEST-TYPE      |        RESERVED       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     DIGEST                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://tools.ietf.org/html/draft-wessels-dns-zone-digest-06
    #>

    [RecordType]       $RecordType = [RecordType]::ZONEMD
    [UInt32]           $Serial
    [ZONEMDDigestType] $DigestType
    [Byte]             $Reserved
    [String]           $Digest

    DnsZONEMDRecord() : base() { }
    DnsZONEMDRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.DigestType = $binaryReader.ReadByte()
        $this.Reserved = $binaryReader.ReadByte()
        $this.Digest = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($this.RecordDataLength - 6))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1:D} {2} {3}' -f @(
            $this.Serial
            $this.DigestType
            $this.Reserved
            $this.Digest -split '(?<=\G.{56})' -join ' '
        )
    }
}