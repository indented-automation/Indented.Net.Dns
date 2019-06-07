class DnsMGRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    MGMNAME                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::MG
    [String]     $MailboxName

    DnsMGRecord() : base() { }
    DnsMGRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.MailboxName = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return $this.MailboxName
    }
}