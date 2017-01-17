using namespace Indented.IO

function ReadDnsAAAARecord {
    # .SYNOPSIS
    #   Reads properties for an AAAA record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ADDRESS                    |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .INPUTS
    #   Indented.IO.EndianBinaryReader
    # .OUTPUTS
    #   Indented.Net.Dns.AAAARecord
    # .LINK
    #   http://www.ietf.org/rfc/rfc3596.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [Parameter(Mandatory = $true)]
        [EndianBinaryReader]$BinaryReader,

        [Parameter(Mandatory = $true)]
        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: IPAddress
    $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv6Address()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.IPAddress.ToString()
    }
}