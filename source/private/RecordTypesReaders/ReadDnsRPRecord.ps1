using namespace Indented.IO

function ReadDnsRPRecord {
    # .SYNOPSIS
    #   RP record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    RMAILBX                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    EMAILBX                    /
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
    #   Indented.DnsResolver.Message.ResourceRecord.RP
    # .LINK
    #   http://www.ietf.org/rfc/rfc1183.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: ResponsibleMailbox
    $ResourceRecord | Add-Member ResponsibleMailbox (ConvertToDnsDomainName $BinaryReader)
    # Property: TXTDomainName
    $ResourceRecord | Add-Member TXTDomainName (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1}' -f $this.ResponsibleMailbox,
                     $this.TXTDomainName
    }
}