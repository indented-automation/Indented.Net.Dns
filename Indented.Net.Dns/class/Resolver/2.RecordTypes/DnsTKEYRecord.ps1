class DnsTKEYRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   ALGORITHM                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   INCEPTION                   |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   EXPIRATION                  |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     MODE                      |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     ERROR                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    KEYSIZE                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    KEYDATA                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   OTHERSIZE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   OTHERDATA                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2930.txt
    #>

    [RecordType] $RecordType = [RecordType]::TKEY
    [String]     $Algorithm
    [DateTime]   $Inception
    [DateTime]   $Expiration
    [TKEYMode]   $Mode
    [RCode]      $TKEYError
    [String]     $KeyData
    [String]     $OtherData

    DnsTKEYRecord() : base() { }
    DnsTKEYRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Algorithm = $binaryReader.ReadDnsDomainName()
        $this.Inception = (Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true))
        # Property: Expiration
        $this.Expiration = (Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true))
        $this.Mode = $binaryReader.ReadUInt16($true)
        $this.TKEYError = $binaryReader.ReadUInt16($true)

        $keySize = $binaryReader.ReadUInt16($true)
        $this.KeyData = [BitConverter]::ToString($binaryReader.ReadBytes($keySize))

        $otherSize = $binaryReader.ReadUInt16($true)
        if ($otherSize -gt 0) {
            $this.OtherData = [BitConverter]::ToString($BinaryReader.ReadBytes($otherSize))
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3} {4} {5}' -f @(
            $this.Algorithm
            $this.Inception.ToString('yyyyMMddHHmmss')
            $this.Expiration.ToString('yyyyMMddHHmmss')
            $this.Mode
            $this.KeyData
            $this.OtherData
        )
    }
}