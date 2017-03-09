using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsTSIGRecord {
    # .SYNOPSIS
    #   TSIG record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   ALGORITHM                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   TIMESIGNED                  |
    #    |                                               |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     FUDGE                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    MACSIZE                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                      MAC                      /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  ORIGINALID                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     ERROR                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   OTHERSIZE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   OTHERDATA                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2845.txt
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
    
    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm (ConvertToDnsDomainName $BinaryReader)
    # Property: TimeSigned
    $ResourceRecord | Add-Member TimeSigned ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt48($true)))
    # Property: Fudge
    $ResourceRecord | Add-Member Fudge ((New-TimeSpan -Seconds ($BinaryReader.ReadUInt16($true))).TotalMinutes)
    # Property: MACSize
    $ResourceRecord | Add-Member MACSize $BinaryReader.ReadBEUInt16()
    # Property: MAC
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.KeySize)
    $ResourceRecord | Add-Member MAC ([EndianBitConverter]::ToString(,$bytes))
    # Property: Error
    $ResourceRecord | Add-Member Error ([RCode]$BinaryReader.ReadUInt16($true))
    # Property: OtherSize
    $ResourceRecord | Add-Member OtherSize $BinaryReader.ReadUInt16($true)

    $otherData = ''
    if ($ResourceRecord.OtherSize -gt 0) {
        $bytes = $BinaryReader.ReadBytes($ResourceRecord.OtherSize)
        $otherData = [EndianBitConverter]::ToString(,$bytes)
    }

    # Property: OtherData
    $ResourceRecord | Add-Member OtherData $otherData

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3} {4}' -f $this.Algorithm,
                                 $this.TimeSigned,
                                 $this.Fudge,
                                 $this.MAC,
                                 $this.OtherData
    }
}