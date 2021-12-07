class DnsTARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    KEYTAG                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |      DIGESTTYPE       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    DIGEST                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
    #>

    [ushort]              $KeyTag
    [EncryptionAlgorithm] $Algorithm
    [DigestType]          $DigestType
    [string]              $Digest

    DnsTARecord() : base() { }
    DnsTARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.KeyTag = $binaryReader.ReadUInt16($true)
        $this.Algorithm = $binaryReader.ReadByte()
        $this.DigestType = $binaryReader.ReadByte()
        $this.Digest = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($this.RecordDataLength - 4))
    }

    hidden [string] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.KeyTag
            $this.Algorithm
            $this.DigestType
            $this.Digest
        )
    }
}
