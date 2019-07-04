class DnsEUI48Record : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    ADDRESS                    |
        |                                               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+


        http://cpansearch.perl.org/src/MIKER/Net-DNS-Codes-0.11/extra_docs/draft-ietf-nimrod-dns-02.txt
    #>

    [RecordType] $RecordType = [RecordType]::EUI48
    [String]     $Address

    DnsEUI48Record() : base() { }
    DnsEUI48Record(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Address = [BitConverter]::ToString($binaryReader.ReadBytes(6)).ToLower()
    }

    hidden [String] RecordDataToString() {
        return $this.Address
    }
}