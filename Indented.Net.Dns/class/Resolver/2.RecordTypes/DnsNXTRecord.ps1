using namespace System.Text

class DnsNXTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   DOMAINNAME                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   <BIT MAP>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2535.txt
        http://www.ietf.org/rfc/rfc3755.txt
    #>

    [RecordType]      $RecordType = [RecordType]::NXT
    [String]          $DomainName
    [DnsRecordType[]] $RRType

    DnsNXTRecord() : base() { }
    DnsNXTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $length = 0
        $this.DomainName = $binaryReader.ReadDnsDomainName([Ref]$length)

        $this.RRType = $binaryReader.ReadBitMap(
            $this.RecordDataLength - $length
        )
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.DomainName,
            ($this.RRType -join ' ')
        )
    }
}