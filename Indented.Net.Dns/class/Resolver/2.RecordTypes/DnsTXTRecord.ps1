class DnsTXTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   TXT-DATA                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1035.txt
    #>

    [RecordType] $RecordType = [RecordType]::TXT
    [String]     $Text

    DnsTXTRecord() : base() { }
    DnsTXTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $recordDataLength = $this.RecordDataLength
        if ($recordDataLength -gt 0) {
            $strings = do {
                $length = 0

                $binaryReader.ReadDnsCharacterString([Ref]$length)

                $recordDataLength -= $length
            } until ($recordDataLength -le 0 -or $length -eq 0)#

            $this.Text = $strings -join ' '
        }
    }

    hidden [String] RecordDataToString() {
        return '"{0}"' -f $this.Text
    }
}