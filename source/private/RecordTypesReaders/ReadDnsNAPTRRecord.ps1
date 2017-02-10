function ReadDnsNAPTRRecord {
    # .SYNOPSIS
    #   Reads properties for an NAPTR record from a byte stream.
    # .DESCRIPTION
    #
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
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Order
    $ResourceRecord | Add-Member Order $BinaryReader.ReadBEUInt16()
    # Property: Preference
    $ResourceRecord | Add-Member Preference $BinaryReader.ReadBEUInt16()
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
        [String]::Format("`n" +
        "    ;;  order    pref  flags  service       regexp              replacement`n" +
        "        {0} {1} {2} {3} {4} {5}",
        $this.Order.ToString().PadRight(8, ' '),
        $this.Preference.ToString().PadRight(5, ' '),
        $this.Flags.PadRight(6, ' '),
        $this.Service.PadRight(13, ' '),
        $this.RegExp.PadRight(19, ' '),
        $this.Replacement)
    }
}