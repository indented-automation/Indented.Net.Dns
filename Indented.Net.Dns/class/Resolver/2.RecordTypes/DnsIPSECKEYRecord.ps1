class DnsIPSECKEYRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |      PRECEDENCE       |      GATEWAYTYPE      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                    GATEWAY                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   PUBLICKEY                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc4025.txt
    #>

    [RecordType]       $RecordType = [RecordType]::IPSECKEY
    [Byte]             $Precedence
    [IPSECGatewayType] $GatewayType
    [IPSECAlgorithm]   $Algorithm
    [String]           $Gateway
    [String]           $PublicKey

    DnsIPSECKEYRecord() : base() { }
    DnsIPSECKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Precedence = $this.ReadByte()
        $this.GatewayType = $this.ReadByte()
        $this.Algorithm = $this.ReadByte()

        $position = $binaryReader.BaseStream.Position

        $this.Gateway = switch ($this.GatewayType) {
            IPv4       { $binaryReader.ReadIPv4Address(); break }
            IPv6       { $binaryReader.ReadIPv6Address(); break }
            DomainName { $binaryReader.ReadDnsDomainName(); break }
        }

        $length = $binaryReader.BaseStream.Position - $position

        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($length))
    }

    hidden [String] RecordDataToString() {
        $format = @(
            ' ( {0} {1} {2}'
            '    {3}'
            '    {4} )'
        ) -join "`n"

        return $format -f @(
            $this.Precedence
            [Byte]$this.GatewayType
            [Byte]$this.Algorithm
            $this.Gateway
            $this.PublicKey
        )
    }
}
