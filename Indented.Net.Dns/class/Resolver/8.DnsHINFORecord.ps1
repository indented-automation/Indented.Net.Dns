using namespace Indented.IO


class DnsHINFORecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      CPU                      /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                       OS                      /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::HINFO
    [String]     $CPU
    [String]     $OS

    DnsHINFORecord() : base() { }
    DnsHINFORecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.CPU = $binaryReader.ReadDnsCharacterString()
        $this.OS = $binaryReader.ReadDnsCharacterString()
    }

    Hidden [String] RecordDataToString() {
        return '"{0}" "{1}"' -f @(
            $this.CPU
            $this.OS
        )
    }
}
