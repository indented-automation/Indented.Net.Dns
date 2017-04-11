using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsMessageQuestion {
    # .SYNOPSIS
    #   Read a DNS question from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                     QNAME                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     QTYPE                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     QCLASS                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [CmdletBinding(DefaultParameterSetName = 'NewQuestion')]
    [OutputType('Indented.Net.Dns.Question')]
    param(
        # A domain-name
        [Parameter(Position = 1, ParameterSetName = 'NewQuestion')]
        [String]$Name = ".",

        # A binary reader.
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'ReadQuestion')]
        [EndianBinaryReader]$BinaryReader
    )

    $dnsMessageQuestion = NewDnsMessageQuestion

    # Property: Name
    $dnsMessageQuestion.Name = ConvertToDnsDomainName $BinaryReader

    # Property: RecordType
    $dnsMessageQuestion.RecordType = [RecordType]$BinaryReader.ReadUInt16($true)

    # Property: RecordClass
    if ($dnsMessageQuestion.RecordType -eq [RecordType]::OPT) {
        $dnsMessageQuestion.RecordClass = $BinaryReader.ReadUInt16($true)
    } else {
        $dnsMessageQuestion.RecordClass = [RecordClass]$BinaryReader.ReadUInt16($true)
    }

    return $dnsMessageQuestion
}