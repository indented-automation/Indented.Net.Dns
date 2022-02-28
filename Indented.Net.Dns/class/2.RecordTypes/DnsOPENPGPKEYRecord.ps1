class DnsOPENPGPKEYRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   TXT-DATA                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [string] $Key

    DnsOPENPGPKEYRecord() : base() { }
    DnsOPENPGPKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Key = [Convert]::ToBase64String($binaryReader.ReadBytes($this.RecordDataLength))
    }

    hidden [string] RecordDataToString() {
        return $this.Key -split '(?<=\G.{56})' -join ' '
    }
}
