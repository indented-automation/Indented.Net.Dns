using namespace Indented
using namespace Indented.Net.Dns

function NewDnsMessageQuestion {
    # .SYNOPSIS
    #   Create a new DNS message question.
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
    #     12/01/2017 - Chris Dent - Modernisation pass.

    [OutputType('Indented.Net.Dns.Question')]
    param(
        # A domain-name.
        [String]$Name,
    
        # The record class, IN by default.
        [RecordClass]$RecordClass = 'IN',

        # The record type for the question. ANY by default.
        [RecordType]$RecordType = 'ANY'
    )

    $dnsMessageQuestion = [PSCustomObject]@{
        Name        = $Name
        RecordClass = $RecordClass
        RecordType  = $RecordType
    } | Add-Member -TypeName 'Indented.Net.Dns.Question' -PassThru

    # Method: ToByte
    $dnsMessageQuestion | Add-Member ToByte -MemberType ScriptMethod -Value {
        $bytes = New-Object System.Collections.Generic.List[Byte]

        $bytes.AddRange((ConvertFromDnsDomainName $this.Name))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordType, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordClass, $true))

        return ,$bytes.ToArray()
    }

    # Method: ToStsring
    $dnsMessageQuestion | Add-Member ToString -MemberType ScriptMethod -Force -Value {
        return '{0}            {1} {2}' -f
            $this.Name.PadRight(29, ' '),
            $this.RecordClass.ToString().PadRight(5, ' '),
            $this.RecordType.ToString().PadRight(5, ' ')
    }

    return $dnsMessageQuestion
}