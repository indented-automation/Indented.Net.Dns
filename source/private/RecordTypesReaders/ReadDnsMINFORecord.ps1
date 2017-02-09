using namespace Indented.IO

function ReadDnsMINFORecord {
    # .SYNOPSIS
    #   Reads properties for an MINFO record from a byte stream.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    RMAILBX                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    EMAILBX                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1035.txt
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: ResponsibleMailbox
    $ResourceRecord | Add-Member ResponsibleMailbox (ConvertToDnsDomainName $BinaryReader)

    # Property: ErrorMailbox
    $ResourceRecord | Add-Member ErrorMailbox (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1}' -f $this.ResponsibleMailbox,
                     $this.ErrorMailbox
    }
}