using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsKEYRecord {
    # .SYNOPSIS
    #   Reads properties for an KEY record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     FLAGS                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        PROTOCOL       |       ALGORITHM       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  PUBLIC KEY                   /
    #    /                                               /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   The flags field takes the following format, discussed in RFC 2535 3.1.2:
    #
    #      0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5
    #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    #    |  A/C  | Z | XT| Z | Z | NAMTYP| Z | Z | Z | Z |      SIG      |
    #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
    #
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Flags
    $ResourceRecord | Add-Member Flags ($BinaryReader.ReadBEUInt16())

    # Property: AuthenticationConfidentiality (bit 0 and 1 of Flags)
    $ResourceRecord | Add-Member AuthenticationConfidentiality ([KEYAC][Byte]($ResourceRecord.Flags -shr 14))

    # Property: FlagsExtension (bit 3)
    if (($ResourceRecord.Flags -band 0x1000) -eq 0x1000) {
        $flagsExtension = $BinaryReader.ReadUInt16($true)
    } else {
        $flagsExtension = 0
    }
    $ResourceRecord | Add-Member FlagsExtension $flagsExtension

    # Property: NameType (bit 6 and 7)
    $ResourceRecord | Add-Member NameType ([KEYNameType][Byte](($ResourceRecord.Flags -band 0x0300) -shr 9))

    # Property: SignatoryField (bit 12 and 15)
    $ResourceRecord | Add-Member SignatoryField ([Boolean]($ResourceRecord.Flags -band 0x000F))

    # Property: Protocol
    $ResourceRecord | Add-Member Protocol ([KEYProtocol]$BinaryReader.ReadByte())

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())

    # Property: PublicKey
    if ($ResourceRecord.AuthenticationConfidentiality -ne [KEYAC]::NoKey) {
        $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
        $publicKey = [Convert]::ToBase64String($bytes)
    } else {
        $publicKey = ''
    }
    $ResourceRecord | Add-Member PublicKey $publicKey
    
    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} ( {3} )' -f $this.Flags,
                                 [Byte]$this.Protocol,
                                 [Byte]$this.Algorithm,
                                 $this.PublicKey
    }
}
