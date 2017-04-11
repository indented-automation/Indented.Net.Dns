using namespace Indented.IO

function ReadDnsNSAPRecord {
    # .SYNOPSIS
    #   NSAP record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                      NSAP                     /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1706.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    $ResourceRecord | Add-Member NSAP (New-Object String(,$BinaryReader.ReadChars($ResourceRecord.RecordDataLength)))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.NSAP
    }
}
