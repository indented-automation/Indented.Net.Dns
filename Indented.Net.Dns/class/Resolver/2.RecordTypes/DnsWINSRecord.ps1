class DnsWINSRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  LOCAL FLAG                   |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                LOOKUP TIMEOUT                 |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 CACHE TIMEOUT                 |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |               NUMBER OF SERVERS               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                SERVER IP LIST                 /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
    #>

    [RecordType]      $RecordType = [RecordType]::WINS
    [WINSMappingFlag] $MappingFlag
    [UInt32]          $LookupTimeout
    [UInt32]          $CacheTimeout
    [IPAddress[]]     $ServerList

    DnsWINSRecord() : base() { }
    DnsWINSRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.MappingFlag = $binaryReader.ReadUInt32($true)
        $this.LookupTimeout = $binaryReader.ReadUInt32($true)
        $this.CacheTimeout = $binaryReader.ReadUInt32($true)

        $numberOfServers = $binaryReader.ReadUInt32($true)

        $this.ServerList = for ($i = 0; $i -lt $numberOfServers; $i++) {
            $binaryReader.ReadIPAddress()
        }
    }

    hidden [String] RecordDataToString() {
        $value = 'L{0} C{1} ( {2} )' -f @(
            $this.LookupTimeout
            $this.CacheTimeout
            ($this.ServerList -join ' ')
        )
        if ($this.MappingFlag -eq 0x10000) {
            return 'LOCAL {0}' -f $value
        }
        return $value
    }
}