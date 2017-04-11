using namespace Indented.IO

function ReadDnsAAAARecord {
    # .SYNOPSIS
    #   AAAA record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ADDRESS                    |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc3596.txt
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: IPAddress
    $ResourceRecord | Add-Member IPAddress $BinaryReader.ReadIPv6Address()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.IPAddress.ToString()
    }
}
