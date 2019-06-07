using namespace System.Collections.Generic
using namespace System.Net.Sockets
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

    [RecordType]   $RecordType = [RecordType]::NXT
    [String]       $DomainName
    [String]       $BitMap
    [RecordType[]] $RRTypes

    DnsNXTRecord() : base() { }
    DnsNXTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $position = $binaryReader.BaseStream.Position

        $this.DomainName = $binaryReader.ReadDnsDomainName()

        $length = $this.RecordDataLength - $binaryReader.BaseStream.Position + $position

        $stringBuilder = [StringBuilder]::new()
        $bitmapBytes = $binaryReader.ReadBytes($length)
        foreach ($byte in $bitmapBytes) {
            $null = $stringBuilder.Append([Convert]::ToString($byte, 2))
        }
        $this.BitMap = $stringBuilder.ToString()

        $this.RRTypes = foreach ($rrType in [RecordType].GetEnumValues()) {
            if ($this.BitMap[[Int]$rrType] -eq 1) {
                $rrType
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.DomainName,
            ($this.RRTypes -join ' ')
        )
    }
}