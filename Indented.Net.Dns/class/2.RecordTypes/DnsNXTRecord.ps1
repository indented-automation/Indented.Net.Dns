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

        $bitMapLength = $this.RecordDataLength - $length
        $bitMap = $binaryReader.ReadBytes($bitMapLength)

        $this.RRType = for ($i = 0; $i -lt $bitMapLength; $i++) {
            for ($j = 7; $j -ge 0; $j--) {
                if ($bitMap[$i] -band 1 -shl $j) {
                    8 * $i + 7 - $j
                }
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.DomainName
            $this.RRType -join ' '
        )
    }
}