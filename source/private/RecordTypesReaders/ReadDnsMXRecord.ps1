using namespace Indented.IO

function ReadDnsMXRecord {
    # .SYNOPSIS
    #   Reads properties for an MX record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  PREFERENCE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   EXCHANGE                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .PARAMETER BinaryReader
    #   A binary reader created by using New-BinaryReader containing a byte array representing a DNS resource record.
    # .PARAMETER ResourceRecord
    #   An Indented.DnsResolver.Message.ResourceRecord object created by ReadDnsResourceRecord.
    # .INPUTS
    #   System.IO.BinaryReader
    #
    #   The BinaryReader object must be created using New-BinaryReader 
    # .OUTPUTS
    #   Indented.DnsResolver.Message.ResourceRecord.MX
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     10/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Preference
    $ResourceRecord | Add-Member Preference $BinaryReader.ReadUInt16($true)
    # Property: Exchange
    $ResourceRecord | Add-Member Exchange (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1}' -f $this.Preference.ToString().PadRight(5, ' '),
                     $this.Exchange
    }
}