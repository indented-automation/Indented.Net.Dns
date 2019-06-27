class DnsWINSRRecord {
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
        |               NUMBER OF DOMAINS               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /               DOMAIN NAME LIST                /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
    #>

    [RecordType]      $RecordType = [RecordType]::WINSR
    [WINSMappingFlag] $MappingFlag
    [UInt32]          $LookupTimeout
    [UInt32]          $CacheTimeout
    [String[]]        $DomainList

    DnsWINSRRecord() : base() { }
    DnsWINSRRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.MappingFlag = $binaryReader.ReadUInt32($true)
        $this.LookupTimeout = $binaryReader.ReadUInt32($true)
        $this.CacheTimeout = $binaryReader.ReadUInt32($true)

        $numberOfDomains = $binaryReader.ReadUInt32($true)
        $this.DomainList = for ($i = 0; $i -lt $numberOfDomains; $i++) {
            $binaryReader.ReadDnsDomainName()
        }
    }

    hidden [String] RecordDataToString() {
        $value = 'L{0} C{1} ( {2} )' -f @(
            $this.LookupTimeout
            $this.CacheTimeout
            ($this.DomainList -join ' ')
        )
        if ($this.MappingFlag -eq 0x10000) {
            return 'LOCAL {0}' -f $value
        }
        return $value
    }
}