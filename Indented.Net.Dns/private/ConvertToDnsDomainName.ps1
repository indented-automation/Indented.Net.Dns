using namespace Indented.IO
using namespace Indented.Net.Dns
using namespace System.Text

function ConvertToDnsDomainName {
    # .SYNOPSIS
    #   Convert a DNS domain name from a byte stream to a string.
    # .DESCRIPTION
    #   DNS messages implement compression to avoid bloat by repeated use of labels.
    #
    #   If a label occurs elsewhere in the message a flag is set and an offset recorded as follows:
    #
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    | 1  1|                OFFSET                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Added BytesRead.
    #     11/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([String])]
    param(
        # A network response stream.
        [Parameter(Mandatory = $true)]
        [EndianBinaryReader]$BinaryReader,

        # A reference allowing the number of bytes read from the stream by this function to be returned.
        [Ref][Int]$BytesRead = [Ref]$null
    )

    $name = New-Object StrinsgBuilder
    [UInt64]$CompressionStart = 0

    $isCompressed = $false
    # Read until we find the null terminator
    while ($BinaryReader.PeekByte() -ne 0) {
        # The length or compression reference
        $length = $BinaryReader.ReadByte()
        if (-not $isCompressed) {
            $BytesRead.Value++
        }

        if (($length -band [MessageCompression]::Enabled) -eq [MessageCompression]::Enabled) {
            $isCompressed = $true

            # Record the current position as the start of the compression operation.
            # Reader will be returned here after this operation is complete.
            if ($compressionStart -eq 0) {
                $compressionStart = $BinaryReader.BaseStream.Position
            }
            # Remove the compression flag bits to calculate the offset value (relative to the start of the message)
            [UInt16]$offset = ([UInt16]($length -bxor [MessageCompression]::Enabled) -shl 8) -bor $BinaryReader.ReadByte()
            # Move to the offset
            $null = $BinaryReader.BaseStream.Seek($offset, 'Begin')
        } else {            
            # Read a label
            $null = $name.Append($BinaryReader.ReadChars($length))
            $null = $name.Append('.')

            if (-not $isCompressed) {
                $BytesRead.Value += $length
            }
        }
    }
    # If expansion was used, return to the starting point (plus 1 byte)
    if ($compressionStart -gt 0) {
        $null = $BinaryReader.BaseStream.Seek($compressionStart, 'Begin')
    }
    # Read off and discard the null termination on the end of the name
    $null = $BinaryReader.ReadByte()
    $BytesRead.Value++

    if ($name[-1] -ne '.') {
        $null = $name.Append('.')
    }

    return $name.ToString()
}