using namespace Indented.IO

function ReadDnsGPOSRecord {
    # .SYNOPSIS
    #   GPOS record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   LONGITUDE                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   LATITUDE                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   ALTITUDE                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1712.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.
        
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Longitude
    $ResourceRecord | Add-Member Longitude (ReadDnsCharacterString $BinaryReader)

    # Property: Latitude
    $ResourceRecord | Add-Member Latitude (ReadDnsCharacterString $BinaryReader)

    # Property: Altitude
    $ResourceRecord | Add-Member Altitude (ReadDnsCharacterString $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f $this.Longitude,
                         $this.Latitude,
                         $this.Altitude
    }
}
