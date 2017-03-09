using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsTARecord {
    # .SYNOPSIS
    #   TA record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    KEYTAG                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       ALGORITHM       |      DIGESTTYPE       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    DIGEST                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: KeyTag
    $ResourceRecord | Add-Member KeyTag $BinaryReader.ReadUInt16($true)
    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())
    # Property: DigestType
    $ResourceRecord | Add-Member DigestType ([DigestType]$BinaryReader.ReadByte())
    # Property: Digest
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
    $ResourceRecord | Add-Member Digest ([EndianBitConverter]::ToString(,$bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}' -f $this.KeyTag,
                             [Byte]$this.Algorithm,
                             [Byte]$this.DigestType,
                             $this.Digest
    }
}