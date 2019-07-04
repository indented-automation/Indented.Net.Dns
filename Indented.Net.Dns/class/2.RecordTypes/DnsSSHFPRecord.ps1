class DnsSSHFPRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       ALGORITHM       |        FPTYPE         |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  FINGERPRINT                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc4255.txt
    #>

    [RecordType]   $RecordType = [RecordType]::SSHFP
    [SSHAlgorithm] $Algorithm
    [SSHFPType]    $FPType
    [String]       $Fingerprint

    DnsSSHFPRecord() : base() { }
    DnsSSHFPRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Algorithm = $binaryReader.ReadByte()
        $this.FPType = $binaryReader.ReadByte()
        $this.FingerPrint = [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($this.RecordDataLength - 2))
    }

    hidden [String] RecordDataToString() {
        return '{0:D} {1:D} {2}' -f @(
            $this.Algorithm
            $this.FPType
            $this.Fingerprint -split '(?<=\G.{56})' -join ' '
        )
    }
}