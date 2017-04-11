using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsMessageHeader {
    # .SYNOPSIS
    #   Read a DNS message header from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      ID                       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    QDCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ANCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    NSCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ARCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.  

    [OutputType('Indented.Net.Dns.Header')]
    param(
        # A binary reader instance attached to the network stream.
        [Parameter(Mandatory = $true)]
        [EndianBinaryReader]$BinaryReader
    )

    $header = NewDnsMessageHeader

    # Property: ID
    $header.ID = $BinaryReader.ReadUInt16($true)

    $Flags = $BinaryReader.ReadUInt16($true)

    # Property: QR
    $header.QR = [QR]($Flags -band 0x8000)
    # Property: OpCode
    $header.OpCode = [OpCode]($Flags -band 0x7800)
    # Property: Flags
    $header.Flags = [Flags]($Flags -band 0x07F0)
    # Property: RCode
    $header.RCode = [RCode]($Flags -band 0x000F)
    # Property: QDCount
    $header.QDCount = $BinaryReader.ReadUInt16($true)
    # Property: ANCount
    $header.ANCount = $BinaryReader.ReadUInt16($true)
    # Property: NSCount
    $header.NSCount = $BinaryReader.ReadUInt16($true)
    # Property: ARCount
    $header.ARCount = $BinaryReader.ReadUInt16($true)

    return $header
}