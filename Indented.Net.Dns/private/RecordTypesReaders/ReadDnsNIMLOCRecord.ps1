using namespace Indented
using namespace Indented.IO

function ReadDnsNIMLOCRecord {
    # .SYNOPSIS
    #   NIMLOC (Nimrod Locator) record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  BinaryData                   /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://ana-3.lcs.mit.edu/~jnc/nimrod/dns.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: BinaryData
    $ResourceRecord | Add-Member BinaryData $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        [BitConverter]::ToString($this.BinaryData)
    }
}
