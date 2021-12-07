class DnsCDSRecord : DnsResourceRecord {
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

        http://www.ietf.org/rfc/rfc7344.txt
    #>

    [ushort]              $KeyTag
    [EncryptionAlgorithm] $Algorithm
    [DigestType]          $DigestType
    [string]              $Digest

    DnsCDSRecord() : base() { }
    DnsCDSRecord(
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

        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 4)
        $this.Digest = [EndianBitConverter]::ToHexadecimal($bytes)
    }

    hidden [string] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.KeyTag
            $this.Algorithm
            $this.DigestType
            $this.Digest -split '(?<=\G.{56})' -join ' '
        )
    }
}
