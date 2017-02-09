using namespace Indented.IO

function ReadDnsCharacterString {
    # .SYNOPSIS
    #   Reads a character-string from a DNS message.
    # .DESCRIPTION
    #   Reads a character-string from a DNS message.
    # .INPUTS
    #   Indented.Net.EndianBinaryReader
    # .OUTPUTS
    #   System.String
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([String])]
    param(
        [EndianBinaryReader]$BinaryReader
    )

    $length = $BinaryReader.ReadByte()
    return New-Object String (,$BinaryReader.ReadChars($length))
}