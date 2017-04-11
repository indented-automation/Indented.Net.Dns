using namespace Indented.IO
using namespace Indented.Net.Dns
using namespace System.IO

function ReadDnsATMARecord {
    # .SYNOPSIS
    #   ATMA record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |         FORMAT        |                       |
    #    +--+--+--+--+--+--+--+--+                       |
    #    /                   ATMADDRESS                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Format
    $format = [ATMAFormat]$BinaryReader.ReadByte()

    # ATMAAddress length, discounting the first byte (Format)
    $length = $RecorceRecord.RecordDataLength - 1
    $address = New-Object StringBuilder

    switch ($Format) {
        ([ATMAFormat]::AESA) {
            for ($i = 0; $i -lt $length; $i++) {
                $null = $address.Append($BinaryReader.ReadChar())
            }
            break
        }
        ([ATMAFormat]::E164) {
            for ($i = 0; $i -lt $length; $i++) {
                if ($i -in 3, 6) {
                    $null = $address.Append('.')
                }
                $null = $address.Append($BinaryReader.ReadChar())
            }
            break
        }
        ([ATMAFormat]::NSAP) {
            for ($i = 0; $i -lt $length; $i++) {
                if ($i -in 1, 3, 13, 19) {
                    $null = $address.Append('.')
                }
                $null = $address.Append(('{0:X2}' -f $BinaryReader.ReadByte()))
            }
            break
        }
    }

    # Property: Format
    $ResourceRecord | Add-Member Format $format

    # Property: ATMAAddress
    $ResourceRecord | Add-Member ATMAAddress $address.ToString()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $this.ATMAAddress
    }
}
