class DnsHIPRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |      HIT LENGTH       |     PK ALGORITHM      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |               PUBLIC KEY LENGTH               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      HIT                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   PUBLIC KEY                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /              RENDEZVOUS SERVERS               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc5205.txt
    #>

    [RecordType]     $RecordType = [RecordType]::HIP
    [IPSECAlgorithm] $PublicKeyAlgorithm
    [String]         $HIT
    [String]         $PublicKey
    [String[]]       $RendezvousServers


    DnsHIPRecord() : base() { }
    DnsHIPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $hitLength = $binaryReader.ReadByte()

        $this.PublicKeyAlgorithm = $binaryReader.ReadByte()

        $publicKeyLength = $binaryReader.ReadUInt16($true)

        $this.HIT = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($hitLength))
        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($publicKeyLength))

        $length = $this.RecordDataLength - 4 - $hitLength - $publicKeyLength
        if ($length -gt 0) {
            $this.RendezvousServers = do {
                $entryLength = 0

                $binaryReader.ReadDnsDomainName([Ref]$entryLength)

                $length -= $entryLength
            } until ($length -le 0)
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3}' -f @(
            [Byte]$this.PublicKeyAlgorithm,
            $this.HIT,
            $this.PublicKey,
            ($this.RendezvousServers -join ' ')
        )
    }
}