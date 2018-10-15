using namespace Indented.IO

function ReadDnsNINFORecord {
    # .SYNOPSIS
    #   NINFO record parser.
    # .DESCRIPTION
    #   Present for legacy support; the NINFO record is marked as obsolete in favour of MX.
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    ZS-DATA                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
    #   http://tools.ietf.org/html/draft-reid-dnsext-zs-01
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.    

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    $list = New-Object List[String]
    $RecordDataLength = $ResourceRecord.RecordDataLength
    if ($RecordDataLength -gt 0) {
        do {
            $BinaryReader.SetMarker()

            $list.Add((ReadDnsCharacterString $BinaryReader))

            $RecordDataLength -= $BinaryReader.BytesFromMarker
        } until ($RecordDataLength -eq 0)
    }

    # Property: RendezvousServers - A container for individual servers
    $ResourceRecord | Add-Member ZSData $list.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.ZSData -join ' '
    }
}
