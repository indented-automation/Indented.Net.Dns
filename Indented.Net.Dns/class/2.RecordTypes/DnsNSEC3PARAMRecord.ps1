class DnsNSEC3PARAMRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       HASH ALG        |         FLAGS         |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   ITERATIONS                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       SALT LEN        |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                      SALT                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc5155.txt
    #>

    [NSEC3HashAlgorithm] $HashAlgorithm
    [Byte]               $Flags
    [UInt16]             $Iterations
    [String]             $Salt = '-'

    DnsNSEC3PARAMRecord() : base() { }
    DnsNSEC3PARAMRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.HashAlgorithm = $binaryReader.ReadByte()
        $this.Flags = $binaryReader.ReadByte()
        $this.Iterations = $binaryReader.ReadUInt16($true)

        $saltLength = $binaryReader.ReadByte()
        if ($saltLength -gt 0) {
            $this.Salt = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($saltLength))
        }
    }

    hidden [String] RecordDataToString() {
        return '{0:D} {1} {2} {3}' -f @(
            $this.HashAlgorithm
            $this.Flags
            $this.Iterations
            $this.Salt
        )
    }
}