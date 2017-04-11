using namespace Indented.IO

function ReadDnsPXRecord {
    # .SYNOPSIS
    #   PX record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  PREFERENCE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   MAP822                      /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   MAPX400                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2163.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Preference
    $ResourceRecord | Add-Member Preference $BinaryReader.ReadUInt16($true)
    # Property: MAP822
    $ResourceRecord | Add-Member MAP822 (ConvertToDnsDomainName $BinaryReader)
    # Property: MAPX400
    $ResourceRecord | Add-Member MAPX400 (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f $this.Preference.ToString().PadRight(5, ' '),
                         $this.MAP822,
                         $this.MAPX400
    }
}