using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsTKEYRecord {
    # .SYNOPSIS
    #   TKEY record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   ALGORITHM                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   INCEPTION                   |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   EXPIRATION                  |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     MODE                      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     ERROR                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    KEYSIZE                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    KEYDATA                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   OTHERSIZE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   OTHERDATA                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2930.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm (ConvertToDnsDomainName $BinaryReader)
    # Property: Inception
    $ResourceRecord | Add-Member Inception ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true)))
    # Property: Expiration
    $ResourceRecord | Add-Member Expiration ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true)))
    # Property: Mode
    $ResourceRecord | Add-Member Mode ([TKEYMode]$BinaryReader.ReadUInt16($true))
    # Property: Error
    $ResourceRecord | Add-Member Error ([RCode]$BinaryReader.ReadUInt16($true))
    # Property: KeySize
    $ResourceRecord | Add-Member KeySize $BinaryReader.ReadUInt16($true)
    # Property: KeyData
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.KeySize)
    $ResourceRecord | Add-Member KeyData ([BitConverter]::ToString($bytes))

    $otherData = ''
    if ($ResourceRecord.OtherSize -gt 0) {
        $bytes = $BinaryReader.ReadBytes($ResourceRecord.OtherSize)
        $otherData = [BitConverter]::ToString($bytes)
    }

    # Property: OtherData
    $ResourceRecord | Add-Member OtherData -MemberType NoteProperty -Value $otherData

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3} {4} {5}' -f $this.Algorithm,
                                     $this.Inception,
                                     $this.Expiration,
                                     $this.Mode,
                                     $this.KeyData,
                                     $this.OtherData
    }
}