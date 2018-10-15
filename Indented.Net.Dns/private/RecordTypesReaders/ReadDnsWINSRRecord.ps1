using namespace Indented.IO
using namespace Indented.Net.Dns
using namespace System.Collections.Generic

function ReadDnsWINSRRecord {
    # .SYNOPSIS
    #   WINSR record parser.
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
    #    /                  DOMAIN NAME                  /
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
    
    # Property: LocalFlag
    $ResourceRecord | Add-Member LocalFlag ([WINSMappingFlag]$BinaryReader.ReadBEUInt32())
    # Property: LookupTimeout
    $ResourceRecord | Add-Member LookupTimeout $BinaryReader.ReadUInt32($true)
    # Property: CacheTimeout
    $ResourceRecord | Add-Member CacheTimeout $BinaryReader.ReadUInt32($true)
    # Property: NumberOfDomains
    $ResourceRecord | Add-Member NumberOfDomains $BinaryReader.ReadUInt32($true)

    $domainNameList = New-Object List[String]
    for ($i = 0; $i -lt $ResourceRecord.NumberOfDomains; $i++) {
        $domainNameList.Add((ConvertToDnsDomainName $BinaryReader))
    }
    # Property: DomainNameList
    $ResourceRecord | Add-Member DomainNameList $domainNameList.ToArray()

    # Property: RecordData
        $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $Value = 'L{0} C{1} ( {2} )' -f $this.LookupTimeout,
                                        $this.CacheTimeout,
                                        ($this.DomainNameList -join ' ')
        if ($this.MappingFlag -eq 0x10000) {
            return 'LOCAL {0}' -f $Value
        }
        return $Value
    }
}