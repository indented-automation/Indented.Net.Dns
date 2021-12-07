class DnsSPFRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   TXT-DATA                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [string[]] $SPF

    DnsSPFRecord() : base() { }
    DnsSPFRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $length = $this.RecordDataLength
        if ($length -gt 0) {
            $this.SPF = do {
                $entryLength = 0

                $binaryReader.ReadDnsCharacterString([ref]$entryLength)

                $length -= $entryLength
            } until ($length -le 0)
        }
    }

    hidden [string] RecordDataToString() {
        return '"{0}"' -f ($this.SPF -join '" "')
    }
}
