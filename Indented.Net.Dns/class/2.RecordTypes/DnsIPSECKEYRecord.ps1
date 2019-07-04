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

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Precedence = $binaryReader.ReadByte()
        $this.GatewayType = $binaryReader.ReadByte()
        $this.Algorithm = $binaryReader.ReadByte()

        $length = 0
        $this.Gateway = switch ($this.GatewayType) {
            IPv4       {
                $binaryReader.ReadIPAddress()
                $length = 4
                break
            }
            IPv6       {
                $binaryReader.ReadIPv6Address()
                $length = 16
                break
            }
            DomainName {
                $binaryReader.ReadDnsDomainName([Ref]$length)
                break
            }
        }
        if ($this.Gateway.Length -eq 0) {
            $this.Gateway = '.'
        }

        $publicKeyLength = $this.RecordDataLength - $length - 3
        $this.PublicKey = [Convert]::ToBase64String($binaryReader.ReadBytes($publicKeyLength))
    }

    hidden [String] RecordDataToString() {
        return '{0} {1:D} {2:D} {3} {4}' -f @(
            $this.Precedence
            $this.GatewayType
            $this.Algorithm
            $this.Gateway
            $this.PublicKey
        )
    }
}
