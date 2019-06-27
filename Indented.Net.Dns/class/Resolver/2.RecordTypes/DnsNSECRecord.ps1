using namespace System.Collections.Generic

class DnsNSECRecord : DnsResourceRecord {
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
    #>

    [RecordType]       $RecordType = [RecordType]::NSEC
    [String]           $DomainName
    [List[RecordType]] $RRType

    DnsNSECRecord() : base() { }
    DnsNSECRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $length = 0
        $this.DomainName = $binaryReader.ReadDnsDomainName([Ref]$length)

        $bitMapLength = $this.RecordDataLength - $length
        $bitMap = [EndianBitConverter]::ToBinary($binaryReader.ReadBytes($bitMapLength))

        $this.RRType = for ($i = 0; $i -lt $bitMap.Length; $i++) {
            if ($bitMap[$i] -eq 1) {
                [RecordType]$i
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.DomainName,
            ($this.RRType -join ' ')
        )
    }
}