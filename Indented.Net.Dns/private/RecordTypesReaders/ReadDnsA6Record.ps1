using namespace Indented.IO

function ReadDnsA6Record {
    # .SYNOPSIS
    #   A6 record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |      PREFIX LEN       |                       |
    #    +--+--+--+--+--+--+--+--+                       |
    #    /                ADDRESS SUFFIX                 /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  PREFIX NAME                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2874.txt
    #   http://www.ietf.org/rfc/rfc3226.txt
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )
    
    # Property: PrefixLength
    $prefixLength = $Reader.ReadByte()
    $ResourceRecord | Add-Member PrefixLength $prefixLength

    # Return the address suffix
    $length = [Math]::Ceiling((128 - $PrefixLength) / 8)
    $addressSuffixBytes = $BinaryReader.ReadBytes($length)

    # Make the AddressSuffix 16 bytes long
    while ($addressSuffixBytes.Length -lt 16) {
        $addressSuffixBytes = @([Byte]0) + $addressSuffixBytes
    }

    $ipv6Address = New-Object IPAddress($addressSuffixBytes)
    
    # Property: AddressSuffix
    $ResourceRecord | Add-Member AddressSuffix $ipv6Address
    # Property: PrefixName
    $ResourceRecord | Add-Member PrefixName (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f $this.PrefixLength.ToString(),
                         $this.AddressSuffix.IPAddressToString,
                         $this.PrefixName
    }
}
