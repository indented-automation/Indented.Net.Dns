using namespace Indented.IO

function ReadDnsHINFORecord {
    # .SYNOPSIS
    #   HINFO record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                      CPU                      /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                       OS                      /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: CPU
    $ResourceRecord | Add-Member CPU (ReadDnsCharacterString $BinaryReader)

    # Property: OS
    $ResourceRecord | Add-Member OS (ReadDnsCharacterString $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        ['"{0}" "{1}"' -f $this.CPU,
                          $this.OS
    }
}
