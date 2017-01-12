function NewDnsMessageQuestion {
    # .SYNOPSIS
    #   Creates a new DNS message question.
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
    # .PARAMETER Name
    #   A name value as a domain-name.
    # .PARAMETER RecordClass
    #   The record class, IN by default.
    # .PARAMETER RecordType
    #   The record type for the question. ANY by default.
    # .INPUTS
    #   System.String
    #   Indented.Net.Dns.RecordClass
    #   Indented.Net.Dns.RecordType
    # .OUTPUTS
    #   Indented.Net.Dns.Question
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     12/01/2017 - Chris Dent - Modernisation pass.

    [CmdletBinding()]
    param(
        [String]$Name,

        [Indented.Net.Dns.RecordClass]$RecordClass = 'IN',

        [Indented.Net.Dns.RecordType]$RecordType = 'ANY'
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
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes([UInt16]$this.RecordType, $true))
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes([UInt16]$this.RecordClass, $true))

        return ,$bytes.ToArray()
    }

    # Method: ToStsring
    $dnsMessageQuestion | Add-Member ToString -MemberType ScriptMethod -Force -Value {
        return '{0}            {1} {2}' -f $this.Name.PadRight(29, ' '),
                                    $this.RecordClass.ToString().PadRight(5, ' '),
                                    $this.RecordType.ToString().PadRight(5, ' ')
    }

    return $dnsMessageQuestion
}