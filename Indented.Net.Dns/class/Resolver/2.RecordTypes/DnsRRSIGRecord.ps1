class DnsRRSIGRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 TYPE COVERED                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |         LABELS        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 ORIGINAL TTL                  |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |             SIGNATURE EXPIRATION              |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |              SIGNATURE INCEPTION              |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    KEY TAG                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                 SIGNER'S NAME                 /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   SIGNATURE                   /
        /                                               /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        .LINK
        http://www.ietf.org/rfc/rfc3755.txt
        http://www.ietf.org/rfc/rfc4034.txt
    #>

    [RecordType]          $RecordType = [RecordType]::RRSIG
    [RecordType]          $TypeCovered
    [EncryptionAlgorithm] $Algorithm
    [Byte]                $Labels
    [UInt32]              $OriginalTTL
    [DateTime]            $SignatureExpiration
    [DateTime]            $SignatureInception
    [UInt16]              $KeyTag
    [String]              $SignersName
    [String]              $Signature

    DnsRRSIGRecord() : base() { }
    DnsRRSIGRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        [Int32]$type = $binaryReader.ReadUInt16($true)
        if ([Enum]::IsDefined([RecordType], $type)) {
            $this.TypeCovered = $typeCoveredValue
        } else {
            $this.TypeCovered = [RecordType]::UNKNOWN
        }

        $this.Algorithm = $binaryReader.ReadByte()
        $this.Labels = $binaryReader.ReadByte()
        $this.OriginalTTL = $binaryReader.ReadUInt32($true)
        $this.SignatureExpiration = (Get-Date '01/01/1970').AddSeconds($binaryReader.ReadUInt32($true))
        $this.SignatureInception = (Get-Date '01/01/1970').AddSeconds($binaryReader.ReadUInt32($true))
        $this.KeyTag = $binaryReader.ReadUInt16($true)

        $length = 0
        $this.SignersName = $binaryReader.ReadDnsDomainName([Ref]$length)
        $this.Signature = [Convert]::ToBase64String($binaryReader.ReadBytes($this.RecordDataLength - 18 - $length))
    }

    hidden [String] RecordDataToString() {
        return @(
            '{0} {1} {2} ( ; type-cov={0}, alg={1}, labels={2}'
            '    {3} ; Signature expiration'
            '    {4} ; Signature inception'
            '    {5} ; Key identifier'
            '    {6} ; Signer'
            '    {7} ; Signature'
            ')'
        ) -join "`n" -f @(
            $this.TypeCovered
            [Byte]$this.Algorithm
            [Byte]$this.Labels
            $this.SignatureExpiration
            $this.SignatureInception
            $this.KeyTag
            $this.SignersName
            $this.Signature
        )
    }
}