using namespace Indented.IO
using namespace Indented.Net

function ReadDnsIPSECKEYRecord {
    # .SYNOPSIS
    #   IPSECKEY record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |      PRECEDENCE       |      GATEWAYTYPE      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       ALGORITHM       |                       /
    #    +--+--+--+--+--+--+--+--+                       /
    #    /                    GATEWAY                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   PUBLICKEY                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc4025.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Precedence
    $ResourceRecord | Add-Member Precedence $BinaryReader.ReadByte()

    # Property: GatewayType
    $ResourceRecord | Add-Member GatewayType ([IPSECGatewayType]$BinaryReader.ReadByte())

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([IPSECAlgorithm]$BinaryReader.ReadByte())

    # Property: Gateway
    $gateway = switch ($ResourceRecord.GatewayType) {
        ([IPSECGatewayType]::NoGateway)  { ''; break }
        ([IPSECGatewayType]::IPv4)       { $BinaryReader.ReadIPv4Address(); break }
        ([IPSECGatewayType]::IPv6)       { $BinaryReader.ReadIPv6Address(); break }
        ([IPSECGatewayType]::DomainName) { ConvertToDnsDomainName $BinaryReader; break }
    }
    $ResourceRecord | Add-Member Gateway -MemberType NoteProperty -Value $gateway

    # Property: PublicKey
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
    $ResourceRecord | Add-Member PublicKey ([Convert]::ToBase64String($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = ' ( {0} {1} {2}', '    {3}', '    {4} )' -join "`n"
        $string -f $this.Precedence,
                   [Byte]$this.GatewayType,
                   [Byte]$this.Algorithm,
                   $this.Gateway,
                   $this.PublicKey
    }
}
