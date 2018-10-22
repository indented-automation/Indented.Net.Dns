class DS : DnsResourceRecord {
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

        http://www.ietf.org/rfc/rfc3658.txt
        http://www.ietf.org/rfc/rfc4034.txt
    #>

    [UInt16]              $KeyTag
    [EncryptionAlgorithm] $Algorithm
    [DigestType]          $DigestType
    [Digest]              $Digest

    DS() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.KeyTag = $binaryReader.ReadInt16($true)
        $this.Algorithm = $binaryReader.ReadByte()
        $this.DigestType = $binaryReader.ReadByte()
        
        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 4)
        $this.Digest = [EndianBitConverter]::ToBinary($bytes)
    }

    [String] RecordDataToString() {
        return '{0} {1} {2} {3}' -f $this.KeyTag.ToString(),
                                    [Byte]$this.Algorithm,
                                    [Byte]$this.DigestType,
                                    $this.Digest
    }
}