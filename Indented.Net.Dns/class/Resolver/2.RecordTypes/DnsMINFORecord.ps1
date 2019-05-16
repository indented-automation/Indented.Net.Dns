using namespace Indented.IO


class DnsMINFORecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    RMAILBX                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    EMAILBX                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::MINFO
    [String]     $ResponsibleMailbox
    [String]     $ErrorMailbox

    DnsMINFORecord() : base() { }
    DnsMINFORecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    Hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.ResponsibleMailbox = $binaryReader.ReadDnsDomainName()
        $this.ErrorMailbox = $binaryReader.ReadDnsDomainName()
    }

    Hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.ResponsibleMailbox
            $this.ErrorMailbox
        )
    }
}