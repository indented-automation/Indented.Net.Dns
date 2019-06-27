class DnsNSEC3Record : DnsResourceRecord {
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
        |       HASH LEN        |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                      HASH                     /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                                               /
        /                   <BIT MAP>                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        The flags field takes the following format, discussed in RFC 5155 3.2:

          0  1  2  3  4  5  6  7
        +--+--+--+--+--+--+--+--+
        |                    |O |
        +--+--+--+--+--+--+--+--+

        Where O, bit 7, represents the Opt-Out Flag.

        http://www.ietf.org/rfc/rfc5155.txt
    #>

    [RecordType]         $RecordType = [RecordType]::NSEC3
    [NSEC3HashAlgorithm] $HashAlgorithm
    [Byte]               $Flags
    [Boolean]            $OptOut
    [UInt16]             $Iterations
    [String]             $Salt
    [String]             $Hash
    [RecordType[]]       $RRType

    DnsNSEC3Record() : base() { }
    DnsNSEC3Record(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.HashAlgorithm = $binaryReader.ReadByte()
        $this.Flags = $binaryReader.ReadByte()
        $this.OptOut = $this.Flags -band [NSEC3Flags]::OptOut
        $this.Iterations = $binaryReader.ReadUInt16($true)

        $saltLength = $binaryReader.ReadByte()
        if ($saltLength -gt 0) {
            $this.Salt = [Convert]::ToBase64String($binaryReader.ReadBytes($saltLength))
        }

        $hashLength = $binaryReader.ReadByte()
        $this.Hash = [Convert]::ToBase64String($binaryReader.ReadBytes($hashLength))

        $bitMapLength = $this.RecordDataLength - 6 - $saltLength - $hashLength
        $bitMap = [EndianBitConverter]::ToBinary($binaryReader.ReadBytes($bitMapLength))

        $this.RRType = for ($i = 0; $i -lt $bitMap.Count; $i++) {
            if ($bitMap[$i] -eq 1) {
                [RecordType]$i
            }
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3} (', '{4} {5} )' -join "`n" -f @(
            [Byte]$this.HashAlgorithm,
            $this.Flags,
            $this.Iterations,
            $this.Salt,
            $this.Hash,
            ($this.RRType -join ' ')
        )
    }
}