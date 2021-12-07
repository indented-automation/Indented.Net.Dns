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

    [string] $NameServer
    [string] $ResponsiblePerson
    [UInt32] $Serial
    [UInt32] $Refresh
    [UInt32] $Retry
    [UInt32] $Expire
    [UInt32] $MinimumTTL

    DnsSOARecord() : base() { }
    DnsSOARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.NameServer = $binaryReader.ReadDnsDomainName()
        $this.ResponsiblePerson = $binaryReader.ReadDnsDomainName()
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.Refresh = $binaryReader.ReadUInt32($true)
        $this.Retry = $binaryReader.ReadUInt32($true)
        $this.Expire = $binaryReader.ReadUInt32($true)
        $this.MinimumTTL = $binaryReader.ReadUInt32($true)
    }

    hidden [string] RecordDataToString() {
        return '{0} {1} {2} {3} {4} {5} {6}' -f @(
            $this.NameServer
            $this.ResponsiblePerson
            $this.Serial
            $this.Refresh
            $this.Retry
            $this.Expire
            $this.MinimumTTL
        )
    }

    hidden [byte[]] RecordDataToByteArray(
        [bool] $useCompressedNames
    ) {
        $bytes = [List[byte]]::new()

        if ($useCompressedNames) {
            # MNAME
            $bytes.AddRange([byte[]](0xC0, 0x0C))
            # RNAME
            $bytes.AddRange([byte[]](0xC0, 0x0C))
        } else {
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.NameServer))
            # RNAME
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.ResponsiblePerson))
        }

        # SerialNumber
        $bytes.AddRange([EndianBitConverter]::GetBytes($this.Serial, $true))
        $bytes.AddRange([byte[]]::new(16))

        return $bytes.ToArray()
    }

    [string] ToLongString() {
        return (@(
            '{0} {1} ('
            '    {2,-10} ; serial'
            '    {3,-10} ; refresh ({4})'
            '    {5,-10} ; retry ({6})'
            '    {7,-10} ; expire ({8})'
            '    {9,-10} ; minimum ttl ({10})'
            ')'
        ) -join "`n") -f @(
            $this.NameServer
            $this.ResponsiblePerson
            $this.Serial
            $this.Refresh
            (ConvertToTimeSpanString -Seconds $this.Refresh)
            $this.Retry
            (ConvertToTimeSpanString -Seconds $this.Retry)
            $this.Expire
            (ConvertToTimeSpanString -Seconds $this.Expire)
            $this.MinimumTTL
            (ConvertToTimeSpanString -Seconds $this.MinimumTTL)
        )
    }
}
