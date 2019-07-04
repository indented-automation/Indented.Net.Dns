class DnsSMIMEARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |      CERT USAGE       |       SELECTOR        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |      MATCHING TYPE    |                       /
        +--+--+--+--+--+--+--+--+                       /
        /              CERT ASSOCIATION DATA            /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://tools.ietf.org/html/rfc8162
    #>

    [RecordType]       $RecordType = [RecordType]::SMIMEA
    [CertificateUsage] $CertificateUsage
    [Selector]         $Selector
    [MatchingType]     $MatchingType
    [String]           $CertificateAssociation

    DnsSMIMEARecord() : base() { }
    DnsSMIMEARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.CertificateUsage = $binaryReader.ReadByte()
        $this.Selector = $binaryReader.ReadByte()
        $this.MatchingType = $binaryReader.ReadByte()
        $this.CertificateAssociation = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($this.RecordDataLength - 3))
    }

    hidden [String] RecordDataToString() {
        return '{0:D} {1:D} {2:D} {3}' -f @(
            $this.CertificateUsage
            $this.Selector
            $this.MatchingType
            $this.CertificateAssociation -split '(?<=\G.{56})' -join ' '
        )
    }
}