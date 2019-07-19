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

    [String]   $Algorithm
    [DateTime] $Inception
    [DateTime] $Expiration
    [TKEYMode] $Mode
    [RCode]    $TKEYError
    [String]   $KeyData
    [String]   $OtherData

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
        $this.Inception = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt32($true))
        $this.Expiration = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt32($true))
        $this.Mode = $binaryReader.ReadUInt16($true)
        $this.TKEYError = $binaryReader.ReadUInt16($true)

        $keySize = $binaryReader.ReadUInt16($true)
        $this.KeyData = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($keySize))

        $otherSize = $binaryReader.ReadUInt16($true)
        if ($otherSize -gt 0) {
            $this.OtherData = [EndianBitConverter]::ToHexadecimal($BinaryReader.ReadBytes($otherSize))
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1:yyyyMMddHHmmss} {2:yyyyMMddHHmmss} {3:D} {4} {5}' -f @(
            $this.Algorithm
            $this.Inception
            $this.Expiration
            $this.Mode
            $this.KeyData
            $this.OtherData
        )
    }
}