using namespace System.Collections.Generic
using namespace System.Text

class DnsNINFORecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    ZS-DATA                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
        http://tools.ietf.org/html/draft-reid-dnsext-zs-01
    #>

    [RecordType] $RecordType = [RecordType]::NINFO
    [String[]]   $ZSData

    DnsNINFORecord() : base() { }
    DnsNINFORecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $recordDataLength = $this.RecordDataLength
        if ($recordDataLength -gt 0) {
            $this.ZSData = do {
                $length = 0

                $binaryReader.ReadDnsCharacterString([Ref]$length)

                $recordDataLength -= $length
            } until ($recordDataLength -le 0 -or $length -eq 0)
        }
    }

    hidden [String] RecordDataToString() {
        return '"{0}"' -f ($this.ZSData -join '" "')
    }
}