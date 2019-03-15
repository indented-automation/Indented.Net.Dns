class DnsDNSKEYRecord : DnsResourceRecord {
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

        The flags field takes the following format, discussed in RFC 4034 2.1.1:

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    | Z|                    | S|
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        Where Z represents the ZoneKey bit, and S the SecureEntryPoint bit.

        http://www.ietf.org/rfc/rfc3755.txt
        http://www.ietf.org/rfc/rfc4034.txt
    #>

    [RecordType]          $RecordType = [RecordType]::DNSKEY
    [UInt16]              $Flags
    [Boolean]             $ZoneKey
    [Boolean]             $SecureEntryPoint
    [KEYProtocol]         $Protocol
    [EncryptionAlgorithm] $Algorithm
    [String]              $PublicKey

    DnsDNSKEYRecord() : base() { }
    DnsDNSKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Flags = $binaryReader.ReadUInt16($true)
        $this.ZoneKey = $this.Flags -band 0x0100
        $this.SecureEntryPoint = $this.Flags -band 0x0001
        $this.Protocol = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 4)
        $this.PublicKey = [Convert]::ToBase64String($bytes)

    }

    [String] RecordDataToString() {
        return '{0} {1} {2} ( {3} )' -f @(
            $this.Flags
            [Byte]$this.Protocol
            [Byte]$this.Algorithm
            $this.PublicKey
        )
    }
}