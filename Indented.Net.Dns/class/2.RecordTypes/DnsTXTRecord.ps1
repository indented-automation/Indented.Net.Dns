class DnsTXTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   TXT-DATA                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [String[]] $Text

    DnsTXTRecord() : base() { }
    DnsTXTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $length = $this.RecordDataLength
        if ($length -gt 0) {
            $this.Text = do {
                $entryLength = 0

                $binaryReader.ReadDnsCharacterString([Ref]$entryLength)

                $length -= $entryLength
            } until ($length -le 0)
        }
    }

    hidden [String] RecordDataToString() {
        return '"{0}"' -f ($this.Text -join '" "')
    }
}