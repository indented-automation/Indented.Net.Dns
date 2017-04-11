using namespace Indented.IO
using namespace Indented.Net.Dns
using namespace System.Collections.Generic

function ReadDnsWINSRecord {
    # .SYNOPSIS
    #   WINS record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  LOCAL FLAG                   |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                LOOKUP TIMEOUT                 |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 CACHE TIMEOUT                 |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |               NUMBER OF SERVERS               |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                SERVER IP LIST                 /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #
    # .LINK
    #   http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: MappingFlag
    $ResourceRecord | Add-Member MappingFlag ([WINSMappingFlag]$BinaryReader.ReadUInt32($true))
    # Property: LookupTimeout
    $ResourceRecord | Add-Member LookupTimeout $BinaryReader.ReadUInt32($true)
    # Property: CacheTimeout
    $ResourceRecord | Add-Member CacheTimeout $BinaryReader.ReadUInt32($true)
    # Property: NumberOfServers
    $ResourceRecord | Add-Member NumberOfServers $BinaryReader.ReadUInt32($true)

    $serverList = New-Object List[IPAddress]
    for ($i = 0; $i -lt $ResourceRecord.NumberOfServers; $i++) {
        $serverList.Add($BinaryReader.ReadIPv4Address())  
    }
    # Property: ServerList
    $ResourceRecord | Add-Member ServerList $serverList.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $Value = 'L{0} C{1} ( {2} )' -f $this.LookupTimeout,
                                        $this.CacheTimeout,
                                        ($this.ServerList -join ' ')
        if ($this.MappingFlag -eq 0x10000) {
            return 'LOCAL {0}' -f $Value
        }
        return $Value
    }
}