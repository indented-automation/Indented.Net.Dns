class DnsEIDRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      EID                      /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+


        http://cpansearch.perl.org/src/MIKER/Net-DNS-Codes-0.11/extra_docs/draft-ietf-nimrod-dns-02.txt
    #>

    [RecordType] $RecordType = [RecordType]::EID
    [String]     $EID

    DnsEIDRecord() : base() { }
    DnsEIDRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.EID = $binaryReader.ReadDnsCharacterString()
    }

    hidden [String] RecordDataToString() {
        return $this.EID
    }
}
