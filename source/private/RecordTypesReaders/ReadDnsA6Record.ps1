using namespace Indented.IO

function ReadDnsA6Record {
    # .SYNOPSIS
    #   Reads properties for an CERT record from a byte stream.
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
    
    # Property: PrefixLength
    $prefixLength = $Reader.ReadByte()
    $ResourceRecord | Add-Member PrefixLength -MemberType NoteProperty -Value $prefixLength

    # Return the address suffix
    $length = [Math]::Ceiling((128 - $PrefixLength) / 8)
    $addressSuffixBytes = $BinaryReader.ReadBytes($length)

    # Make the AddressSuffix 16 bytes long
    while ($addressSuffixBytes.Length -lt 16) {
        $addressSuffixBytes = @([Byte]0) + $addressSuffixBytes
    }

    $ipv6Address = New-Object IPAddress($addressSuffixBytes)
    
    # Property: AddressSuffix
    $ResourceRecord | Add-Member AddressSuffix -MemberType NoteProperty -Value $ipv6Address
    # Property: PrefixName
    $ResourceRecord | Add-Member PrefixName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f
            $this.PrefixLength.ToString(),
            $this.AddressSuffix.IPAddressToString,
            $this.PrefixName
    }
}