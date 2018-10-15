using namespace Indented.IO

function ReadDnsCharacterString {
    # .SYNOPSIS
    #   Read a character-string from a DNS message.
    # .DESCRIPTION
    #   Read a character-string from a DNS message.
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([String])]
    param(
        [EndianBinaryReader]$BinaryReader
    )

    $length = $BinaryReader.ReadByte()
    return New-Object String (,$BinaryReader.ReadChars($length))
}