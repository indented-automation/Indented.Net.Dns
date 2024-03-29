class DnsCDNSKEYRecord : DnsResourceRecord {
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

        http://www.ietf.org/rfc/rfc7344.txt
    #>

    [UInt16]              $Flags
    [bool]             $ZoneKey
    [bool]             $SecureEntryPoint
    [KEYProtocol]         $Protocol
    [EncryptionAlgorithm] $Algorithm
    [string]              $PublicKey

    DnsCDNSKEYRecord() : base() { }
    DnsCDNSKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Flags = $binaryReader.ReadUInt16($true)
        $this.ZoneKey = $this.Flags -band 0x0100
        $this.SecureEntryPoint = $this.Flags -band 0x0001
        $this.Protocol = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 4)
        $this.PublicKey = [Convert]::ToBase64String($bytes)

    }

    hidden [string] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.Flags
            $this.Protocol
            $this.Algorithm
            $this.PublicKey -split '(?<=\G.{56})' -join ' '
        )
    }
}
