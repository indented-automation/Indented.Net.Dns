using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsDLVRecord {
    # .SYNOPSIS
    #   DLV record parser.
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
    #   http://www.ietf.org/rfc/rfc4431.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: KeyTag
    $ResourceRecord | Add-Member KeyTag $BinaryReader.ReadInt16($true)

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())
    
    # Property: DigestType
    $ResourceRecord | Add-Member DigestType ([DigestType]$BinaryReader.ReadByte())
    
    # Property: Digest
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
    $ResourceRecord | Add-Member Digest ([EndianBitConverter]::ToString($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}' -f $this.KeyTag.ToString(),
                             [Byte]$this.Algorithm,
                             [Byte]$this.DigestType,
                             $this.Digest
    }
}
