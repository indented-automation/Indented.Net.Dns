using namespace Indented.IO

function ReadDnsISDNRecord {
    # .SYNOPSIS
    #   ISDN record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                ISDNADDRESS                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                 SUBADDRESS                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1183.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: ISDNAddress
    $ResourceRecord | Add-Member ISDNAddress (ReadDnsCharacterString $BinaryReader)

    # Property: SubAddress
    $ResourceRecord | Add-Member SubAddress (ReadDnsCharacterString $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '"{0}" "{1}"' -f $this.ISDNAddress,
                         $this.SubAddress
    }
}
