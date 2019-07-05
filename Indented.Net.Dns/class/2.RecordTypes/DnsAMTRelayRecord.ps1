class DnsAMTRelayRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       PRECEDENCE      | D|        TYPE        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     RELAY                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://tools.ietf.org/html/draft-ietf-mboned-driad-amt-discovery-06
    #>

    [Byte]         $Precedence
    [Boolean]      $DiscoveryOptional
    [AMTRelayType] $Type
    [String]       $Relay

    DnsAMTRelayRecord() : base() { }
    DnsAMTRelayRecord(
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

        $discoveryAndType = $binaryReader.ReadByte()

        $this.DiscoveryOptional = $discoveryAndType -band 0x80
        $this.Type = $discoveryAndType -band 0x7F

        if ($this.Type -ne 'None') {
            $this.Relay = switch ($this.Type) {
                IPv4       {
                    $binaryReader.ReadIPAddress()
                    break
                }
                IPv6       {
                    $binaryReader.ReadIPv6Address()
                    break
                }
                DomainName {
                    $binaryReader.ReadDnsDomainName()
                    break
                }
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1:D} {2:D} {3}' -f @(
            $this.Precedence
            [Byte]$this.DiscoveryOptional
            $this.Type
            $this.Relay
        )
    }
}
