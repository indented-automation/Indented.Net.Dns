using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsAPLRecord {
    # .SYNOPSIS
    #   Reads properties for an APL record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 ADDRESSFAMILY                 |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        PREFIX         | N|     AFDLENGTH      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    AFDPART                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://tools.ietf.org/html/rfc3123
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    $list = New-Object List[PSObject]

    # RecordData handling - a counter to decrement
    $recordDataLength = $ResourceRecord.RecordDataLength
    if ($recordDataLength -gt 0) {
        do {
            $BinaryReader.SetMarker()

            $item = [PSCustomObject]@{
                AddressFamily = [IanaAddressFamily]$BinaryReader.ReadUInt16($true)
                Prefix        = $BinaryReader.ReadByte()
                Negation      = $false
                AddressLength = 0
                Address       = $null
            }

            $negationAndLength = $BinaryReader.ReadByte()

            # Property: Negation
            $item.Negation = [Boolean]($negationAndLength -band 0x0800)

            # Property: AddressLength
            $item.AddressLength = $negationAndLength -band 0x007F

            $addressLength = [Math]::Ceiling($ResourceRecord.AddressLength / 8)
            $addressBytes = $BinaryReader.ReadBytes($addressLength)

            switch ($item.AddressFamily) {
                ([IanaAddressFamily]::IPv4) {
                    while ($addressBytes.Length -lt 4) {
                        $addressBytes = @([Byte]0) + $addressBytes
                    }                        
                    break
                }
                ([IanaAddressFamily]::IPv6) {
                    while ($addressBytes.Length -lt 16) {
                        $addressBytes = @([Byte]0) + $addressBytes
                    }
                    break
                }
            }

            # Property: Address
            $item.Address = New-Object IPAddress($addressBytes)

            $list.Add($item)

            $recordDataLength -= $BinaryReader.BytesFromMarker
        } until ($recordDataLength -eq 0)
    }

    # Property: List
    $ResourceRecord | Add-Member List $list.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $values = foreach ($item in $list) {
            '{0}{1}:{2}/{3}' -f ('', '!')[$item.Negation],
                                [UInt16]$item.AddressFamily,
                                $item.Address,
                                $item.Prefix
        }
        if ($Values.Count -gt 1) {
            "( $values )"
        } else {
            $values
        }
    }
}
