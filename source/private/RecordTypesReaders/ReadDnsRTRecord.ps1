using namespace Indented.IO

function ReadDnsRTRecord {
    # .SYNOPSIS
    #   RT record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  PREFERENCE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   EXCHANGE                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1183.txt
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
    # Property: IntermediateHost
    $ResourceRecord | Add-Member IntermediateHost (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1}' -f $this.Preference.ToString().PadRight(5, ' '),
                     $this.IntermediateHost
    }
}