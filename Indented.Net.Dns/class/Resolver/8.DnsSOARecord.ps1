using namespace System.Collections.Generic

class DnsSOARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     MNAME                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     RNAME                     /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    SERIAL                     |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    REFRESH                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     RETRY                     |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    EXPIRE                     |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    MINIMUM                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::SOA
    [String]     $NameServer
    [String]     $ResponsiblePerson
    [UInt32]     $Serial
    [UInt32]     $Refresh
    [UInt32]     $Retry
    [UInt32]     $Expire
    [UInt32]     $MinimumTTL

    DnsSOARecord() : base() { }
    DnsSOARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.NameServer = $binaryReader.ReadDnsDomainName()
        $this.ResponsiblePerson = $binaryReader.ReadDnsDomainName()
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.Refresh = $binaryReader.ReadUInt32($true)
        $this.Retry = $binaryReader.ReadUInt32($true)
        $this.Expire = $binaryReader.ReadUInt32($true)
        $this.MinimumTTL = $binaryReader.ReadUInt32($true)
    }

    Hidden [String] RecordDataToString() {
        $string = @(
            '{0} {1} ('
            '    {2} ; serial'
            '    {3} ; refresh ({4})'
            '    {5} ; retry ({6})'
            '    {7} ; expire ({8})'
            '    {9} ; minimum ttl ({10})'
            ')'
        ) -join "`n"
        return $string -f @(
            $this.NameServer,
            $this.ResponsiblePerson,
            $this.Serial.ToString().PadRight(10, ' '),
            $this.Refresh.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Refresh),
            $this.Retry.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Retry),
            $this.Expire.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Expire),
            $this.MinimumTTL.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Refresh)
        )
    }

    Hidden [IEnumerable[Byte]] RecordDataToByteArray(
        [Boolean] $useCompressedNames
    ) {
        $bytes = [List[Byte]]::new()

        if ($useCompressedNames) {
            # MNAME
            $bytes.AddRange([Byte[]](0xC0, 0x0C))
            # RNAME
            $bytes.AddRange([Byte[]](0xC0, 0x0C))
        } else {
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.NameServer))
            # RNAME
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.ResponsiblePerson))
        }

        # SerialNumber
        $bytes.AddRange([EndianBitConverter]::GetBytes($this.Serial, $true))
        $bytes.AddRange([Byte[]]::new(16))

        return ,$bytes
    }
}