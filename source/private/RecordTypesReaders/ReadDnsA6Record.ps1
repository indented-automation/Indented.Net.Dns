function ReadDnsA6Record {
    # .SYNOPSIS
    #   Reads properties for an CERT record from a byte stream.
    # .DESCRIPTION
    #   Internal use only.
    #
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
    # .INPUTS
    #   System.IO.BinaryReader (New-BinaryReader) 
    # .OUTPUTS
    #   System.Management.Automation.PSObject (Indented.Net.Dns.Records.A6)
    # .LINK
    #   http://www.ietf.org/rfc/rfc2874.txt
    #   http://www.ietf.org/rfc/rfc3226.txt

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.BinaryReader]$BinaryReader,

        [Parameter(Mandatory = $true)]
        [PSTypeName('Indented.DnsResolver.ResourceRecord')]
        $ResourceRecord
    )

    $ResourceRecord | Add-Member -TypeName 'Indented.Net.Dns.ResourceRecord.A6'

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

    # Convert the address bytes to an IPv6 style string
    $ipv6AddressArray = @()
    for ($i = 0; $i -lt 16; $i += 2) {
        $ipv6AddressArray += '{0:X2}{1:X2}' -f $AddressSuffixBytes[$i],
                                               $AddressSuffixBytes[$i + 1]
    }
    $ipv6Address = [IPAddress]($ipv6AddressArray -join ':')

    # Property: AddressSuffix
    $ResourceRecord | Add-Member AddressSuffix -MemberType NoteProperty -Value $ipv6Address
    # Property: PrefixName
    $ResourceRecord | Add-Member PrefixName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f $this.PrefixLength.ToString(),
                         $this.AddressSuffix.IPAddressToString,
                         $this.PrefixName
    }

    return $ResourceRecord
}