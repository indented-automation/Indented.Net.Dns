using namespace System.Net.Sockets
using namespace System.Text

class DnsWKSRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    ADDRESS                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       PROTOCOL        |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                                               /
        /                   <BIT MAP>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
        http://www.ietf.org/rfc/rfc1010.txt
    #>

    [IPAddress]    $IPAddress
    [Byte]         $IPProtocolNumber
    [ProtocolType] $IPProtocolType
    [String]       $BitMap
    [UInt16[]]     $Ports

    DnsWKSRecord() : base() { }
    DnsWKSRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.IPAddress = $binaryReader.ReadIPAddress()
        $this.IPProtocolNumber = $binaryReader.ReadByte()
        $this.IPProtocolType = $this.IPProtocolNumber

        $bitmapBytes = $binaryReader.ReadBytes($this.RecordDataLength - 5)
        foreach ($byte in $bitmapBytes) {
            $this.BitMap += [Convert]::ToString($byte, 2).PadLeft(8, '0')
        }

        $this.Ports = for ($i = 0; $i -lt $this.BitMap.Length; $i++) {
            if ($this.BitMap[$i] -eq '1') {
                $i
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2}' -f @(
            $this.IPAddress
            $this.IPProtocolNumber
            $this.Ports -join ' '
        )
    }
}