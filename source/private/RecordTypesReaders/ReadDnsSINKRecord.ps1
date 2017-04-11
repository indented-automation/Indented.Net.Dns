using namespace Indented.IO

function ReadDnsSINKRecord {
    # .SYNOPSIS
    #   SINK record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        CODING         |       SUBCODING       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                     DATA                      /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://tools.ietf.org/id/draft-eastlake-kitchen-sink-02.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )
    
    # Property: Coding
    $ResourceRecord | Add-Member Coding $BinaryReader.ReadByte()
    # Property: Subcoding
    $ResourceRecord | Add-Member Subcoding $BinaryReader.ReadByte()
    # Property: Data
    $ResourceRecord | Add-Member Data $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 2)
}