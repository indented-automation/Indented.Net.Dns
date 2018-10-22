class CERT : DnsResourceRecord {
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

    CERT() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.CertificateType = $binaryReader.ReadUInt16($true)
        $this.KeyTag = $binaryReader.ReadUInt16($true)
        $this.Algorithm = $binaryReader.ReadByte()
        
        # Property: Certificate
        $bytes = $binaryReader.ReadBytes($this.RecordDataLength - 5)
        $this.Certificate = [Convert]::ToBase64String($bytes)
    }

    [String] RecordDataToString() {
        return '{0} {1} {2} {3}' -f $this.CertificateType.ToString(),
                                    [UInt16]$this.KeyTag,
                                    [UInt16]$this.Algorithm,
                                    $this.Certificate
    }
}