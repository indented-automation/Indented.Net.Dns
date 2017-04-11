function ReadDnsSOARecord {
    # .SYNOPSIS
    #   SOA record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                     MNAME                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                     RNAME                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    SERIAL                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    REFRESH                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     RETRY                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    EXPIRE                     |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    MINIMUM                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: NameServer
    $ResourceRecord | Add-Member NameServer (ConvertToDnsDomainName $BinaryReader)
    # Property: ResponsiblePerson
    $ResourceRecord | Add-Member ResponsiblePerson (ConvertToDnsDomainName $BinaryReader)
    # Property: Serial
    $ResourceRecord | Add-Member Serial $BinaryReader.ReadUInt32($true)
    # Property: Refresh
    $ResourceRecord | Add-Member Refresh $BinaryReader.ReadUInt32($true)
    # Property: Retry
    $ResourceRecord | Add-Member Retry $BinaryReader.ReadUInt32($true)
    # Property: Expire
    $ResourceRecord | Add-Member Expire $BinaryReader.ReadUInt32($true)
    # Property: MinimumTTL
    $ResourceRecord | Add-Member MinimumTTL $BinaryReader.ReadUInt32($true)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = '{0} {1} (',
                  '    {2} ; serial',
                  '    {3} ; refresh ({4})',
                  '    {5} ; retry ({6})',
                  '    {7} ; expire ({8})',
                  '    {9} ; minimum ttl ({10})',
                  ')'
        $string -f $this.NameServer,
                   $this.ResponsiblePerson,
                   $this.Serial.ToString().PadRight(10, ' '),
                   $this.Refresh.ToString().PadRight(10, ' '),
                   (ConvertTo-TimeSpanString -Seconds $this.Refresh),
                   $this.Retry.ToString().PadRight(10, ' '),
                   (ConvertTo-TimeSpanString -Seconds $this.Retry),
                   $this.Expire.ToString().PadRight(10, ' '),
                   (ConvertTo-TimeSpanString -Seconds $this.Expire),
                   $this.MinimumTTL.ToString().PadRight(10, ' '),
                   (ConvertTo-TimeSpanString -Seconds $this.Refresh)
    }
}