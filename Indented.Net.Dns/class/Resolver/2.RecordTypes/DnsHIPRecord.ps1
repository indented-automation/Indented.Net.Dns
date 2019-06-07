using namespace System.Collections.Generic

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

    [RecordType]     $RecordType        = [RecordType]::HIP
    [Byte]           $HITLength
    [IPSECAlgorithm] $PublicKeyAlgorithm
    [UInt16]         $PublicKeyLength
    [String]         $HIT
    [String]         $PublicKey
    [List[String]]   $RendezvousServers = [List[String]]::new()


    DnsHIPRecord() : base() { }
    DnsHIPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.HITLength = $this.ReadByte()
        $this.PublicKeyAlgorithm = $this.ReadByte()
        $this.PublicKeyLength = $this.ReadUInt16($true)
        $this.HIT = [EndianBitConverter]::ToString($binaryReader.ReadBytes($this.HITLength))
        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($this.PublicKeyLength))

        $length = $this.RecordDataLength - 4 - $this.HITLength - $this.PublicKeyLength
        if ($length -gt 0) {
            do {
                $position = $binaryReader.BaseStream.Position

                $this.RendezvousServers.Add($binaryReader.ReadDnsDomainName([Ref]))

                $length = $length - $binaryReader.BaseStream.Position + $position
            } until ($length -eq 0)
        }
    }

    hidden [String] RecordDataToString() {
        $format = @(
            '( {0} {1}',
            '    {2}',
            '    {3} )'
        ) -join "`n"

        return $format -f @(
            [Byte]$this.Algorithm,
            $this.HIT,
            $this.PublicKey,
            ($this.RendezvousServers -join "`n")
        )
    }
}