class DnsCERTRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     TYPE                      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    KEY TAG                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |                       |
        +--+--+--+--+--+--+--+--+                       |
        /               CERTIFICATE or CRL              /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc4398.txt
    #>

    [CertificateType]     $CertificateType
    [UInt16]              $KeyTag
    [EncryptionAlgorithm] $Algorithm
    [String]              $Certificate

    DnsCERTRecord() : base() { }
    DnsCERTRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.CertificateType = $binaryReader.ReadUInt16($true)
        $this.KeyTag = $binaryReader.ReadUInt16($true)
        $this.Algorithm = $binaryReader.ReadByte()

        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 5)
        $this.Certificate = [Convert]::ToBase64String($bytes)
    }

    hidden [String] RecordDataToString() {
        return '{0:D} {1:D} {2} {3}' -f @(
            $this.CertificateType
            $this.KeyTag
            $this.Algorithm
            $this.Certificate -split '(?<=\G.{56})' -join ' '
        )
    }
}