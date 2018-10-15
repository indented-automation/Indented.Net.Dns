using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsNSECRecord {
    # .SYNOPSIS
    #   NSEC record parser.
    # .DESCRIPTION
    #   Internal use only.
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   DOMAINNAME                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   <BIT MAP>                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc3755.txt
    #   http://www.ietf.org/rfc/rfc4034.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.
    
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: DomainName
    $length = 0
    $ResourceRecord | Add-Member DomainName (ConvertToDnsDomainName $BinaryReader -BytesRead ([Ref]$length))

    # Property: RRTypeBitMap
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $length)
    $ResourceRecord | Add-Member RRTypeBitMap ([EndianBitConverter]::ToBinary($bytes))

    # Property: RRTypes
    $rrTypes = New-Object List[String]
    foreach ($rrType in [Enum]::GetValues([RecordType])) {
        if ($ResourceRecord.RRTypeBitMap[[Int]$rrType] -eq 1) {
            $rrTypes.Add($rrType)
        }
    }
    $ResourceRecord | Add-Member RRTypes $rrTypes.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    '{0} {1} {2}' -f $this.DomainName,
                     ($this.RRTypes -join ' ')
    }
}
