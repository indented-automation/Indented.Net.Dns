class DnsEIDRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      EID                      /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+


        http://cpansearch.perl.org/src/MIKER/Net-DNS-Codes-0.11/extra_docs/draft-ietf-nimrod-dns-02.txt
    #>

    [string] $EID

    DnsEIDRecord() : base() { }
    DnsEIDRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.EID = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($this.RecordDataLength))
    }

    hidden [string] RecordDataToString() {
        return $this.EID
    }
}
