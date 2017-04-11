using namespace Indented.IO
using namespace System.Net.Sockets

function ReadDnsWKSRecord {
    # .SYNOPSIS
    #   WKS record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ADDRESS                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       PROTOCOL        |                       /
    #    +--+--+--+--+--+--+--+--+                       /
    #    /                                               /
    #    /                   <BIT MAP>                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    #   http://www.ietf.org/rfc/rfc1010.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )
    
    # Property: IPAddress
    $ResourceRecord | Add-Member IPAddress $BinaryReader.ReadIPv4Address()
    # Property: IPProtocolNumber
    $ResourceRecord | Add-Member IPProtocolNumber $BinaryReader.ReadByte()
    # Property: IPProtocolType
    $ResourceRecord | Add-Member IPProtocolType ([ProtocolType]$ResourceRecord.IPProtocolNumber)
    # Property: BitMap
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 5)
    $ResourceRecord | Add-Member BitMap ([EndianBitConverter]::ToBinary(,$bytes))
    # Property: Ports (numeric)
    $ports = New-Object List[UInt16]
    for ([UInt16]$i = 0; $i -lt $ResourceRecord.BitMap.Length; $i++) {
        if ($ResourceRecord.BitMap[$i] -eq 1) {
            $ports.Add($i)
        }
    }
    $ResourceRecord | Add-Member Ports $ports.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} ( {2} )' -f $this.IPAddress,
                             $this.IPProtocolType,
                             ($this.Ports -join ' ')
    }
}