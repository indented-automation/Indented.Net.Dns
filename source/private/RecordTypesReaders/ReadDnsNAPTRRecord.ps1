using namespace Indented.IO

function ReadDnsNAPTRRecord {
    # .SYNOPSIS
    #   NAPTR record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     ORDER                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   PREFERENCE                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                     FLAGS                     /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   SERVICES                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    REGEXP                     /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  REPLACEMENT                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2915.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Order
    $ResourceRecord | Add-Member Order $BinaryReader.ReadUInt16($true)
    # Property: Preference
    $ResourceRecord | Add-Member Preference $BinaryReader.ReadUInt16($true)
    # Property: Flags
    $ResourceRecord | Add-Member Flags (ReadDnsCharacterString $BinaryReader)
    # Property: Service
    $ResourceRecord | Add-Member Service (ReadDnsCharacterString $BinaryReader)
    # Property: RegExp
    $ResourceRecord | Add-Member RegExp (ReadDnsCharacterString $BinaryReader)
    # Property: Replacement
    $ResourceRecord | Add-Member RegExp (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = '',
            '    ;;  order    pref  flags  service       regexp              replacement',
            '        {0} {1} {2} {3} {4} {5}' -join "`n"
        $string -f $this.Order.ToString().PadRight(8, ' '),
                   $this.Preference.ToString().PadRight(5, ' '),
                   $this.Flags.PadRight(6, ' '),
                   $this.Service.PadRight(13, ' '),
                   $this.RegExp.PadRight(19, ' '),
                   $this.Replacement
    }
}
