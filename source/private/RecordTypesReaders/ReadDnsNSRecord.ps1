using namespace Indented.IO

function ReadDnsNSRecord {
    # .SYNOPSIS
    #   Reads properties for an NS record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   NSDNAME                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.
    
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Hostname
    $ResourceRecord | Add-Member Hostname (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.Hostname
    }
}
