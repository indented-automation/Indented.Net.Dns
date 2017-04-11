using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsHIPRecord {
    # .SYNOPSIS
    #   HIP record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |      HIT LENGTH       |     PK ALGORITHM      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |               PUBLIC KEY LENGTH               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                      HIT                      /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   PUBLIC KEY                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /              RENDEZVOUS SERVERS               /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc5205.txt
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.
    
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: HITLength
    $ResourceRecord | Add-Member HIPLength $BinaryReader.ReadByte()

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([IPSECAlgorithm]$BinaryReader.ReadByte())

    # Property: PublicKeyLength
    $ResourceRecord | Add-Member PublicKeyLength $BinaryReader.ReadUInt16($true)

    # Property: HIT
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.HITLength)
    $ResourceRecord | Add-Member HIT ([EndianBitConverter]::ToString($bytes))

    # Property: PublicKey
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.PublicKeyLength)
    $ResourceRecord | Add-Member PublicKey ([Convert]::ToBase64String($bytes))  

    # Property: RendezvousServers - A container for individual servers
    $ResourceRecord | Add-Member RendezvousServers @()

    # RecordData handling - a counter to decrement
    $length = $ResourceRecord.RecordDataLength
    if ($length -gt 0) {
        do {
            $BinaryReader.SetMarker()

            $ResourceRecord.RendezvousServers += (ReadDnsDomainName $BinaryReader)

            $length -= $BinaryReader.BytesFromMarker
        } until ($length -eq 0)
    }

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = '( {0} {1}', '    {2}', '    {3} )' -join "`n"
        $string -f [Byte]$this.Algorithm,
                   $this.HIT,
                   $this.PublicKey,
                   ($this.RendezvousServers -join "`n")
    }
}
