using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsAFSDBRecord {
    # .SYNOPSIS
    #   AFSDB record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    SUBTYPE                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                    HOSTNAME                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1183.txt
    # .NOTES
    #   Change log:
    #     17/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: SubType
    $subType = $BinaryReader.ReadUInt16($true)
    if ([Enum]::IsDefined([AFSDBSubType], $subType)) {
        $subType = [AFSDBSubType]$subType
    }
    $ResourceRecord | Add-Member SubType $subType

    # Property: Hostname
    $ResourceRecord | Add-Member Hostname (ConvertToDnsDomainName $BinaryReader)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        return '{0} {1}' -f $this.SubType,
                            $this.Hostname
    }
}
