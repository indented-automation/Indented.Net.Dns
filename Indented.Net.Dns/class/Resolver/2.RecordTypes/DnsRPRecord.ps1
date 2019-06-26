class DnsRPRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    RMAILBX                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    TXTDNAME                   /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1183.txt
    #>

    [RecordType] $RecordType = [RecordType]::RP
    [String]     $ResponsibleMailbox
    [String]     $DomainName

    DnsRPRecord() : base() { }
    DnsRPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.ResponsibleMailbox = $binaryReader.ReadDnsDomainName()
        $this.DomainName = $binaryReader.ReadDnsDomainName()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.ResponsibleMailbox
            $this.DomainName
        )
    }
}