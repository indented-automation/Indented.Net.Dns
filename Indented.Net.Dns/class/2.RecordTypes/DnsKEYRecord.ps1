class DnsKEYRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     FLAGS                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        PROTOCOL       |       ALGORITHM       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  PUBLIC KEY                   /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        The flags field takes the following format, discussed in RFC 2535 3.1.2:

          0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5
        +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
        |  A/C  | Z | XT| Z | Z | NAMTYP| Z | Z | Z | Z |      SIG      |
        +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    #>

    [UInt16]              $Flags
    [KEYAC]               $AuthenticationConfidentiality
    [UInt16]              $FlagsExtension
    [KEYNameType]         $NameType
    [Boolean]             $SignatoryField
    [KEYProtocol]         $Protocol
    [EncryptionAlgorithm] $Algorithm
    [String]              $PublicKey

    DnsKEYRecord() : base() { }
    DnsKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Flags = $binaryReader.ReadUInt16($true)
        $this.AuthenticationConfidentiality = [Byte]($this.Flags -shr 14)

        if (($this.Flags -band 0x1000) -eq 0x1000) {
            $this.FlagsExtension = $binaryReader.ReadUInt16($true)
        }

        $this.NameType = ($this.Flags -band 0x0300) -shr 9
        $this.SignatoryField = $this.Flags -band 0x000F
        $this.Protocol = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $length = $this.RecordDataLength - 4
        if ($this.AuthenticationConfidentiality -ne 'NoKey' -and $length -gt 0) {
            $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($length))
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.Flags
            $this.Protocol
            $this.Algorithm
            $this.PublicKey -split '(?<=\G.{56})' -join ' '
        )
    }
}
