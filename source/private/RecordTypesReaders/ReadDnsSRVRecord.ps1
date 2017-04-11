function ReadDnsSRVRecord {
    # .SYNOPSIS
    #   SRV record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   PRIORITY                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    WEIGHT                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     PORT                      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    TARGET                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2782.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Priority
    $ResourceRecord | Add-Member Priority $BinaryReader.ReadUInt16($true)
    # Property: Weight
    $ResourceRecord | Add-Member Weight $BinaryReader.ReadUInt16($true)
    # Property: Port
    $ResourceRecord | Add-Member Port $BinaryReader.ReadUInt16($true)
    # Property: Hostname
    $ResourceRecord | Add-Member Hostname (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}' -f $this.Priority,
                             $this.Weight,
                             $this.Port,
                             $this.Hostname
    }
}