class DnsCSYNCRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     SERIAL                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     FLAGS                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                 TYPE BIT MAP                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc7477.txt
    #>

    [RecordType]      $RecordType = [RecordType]::CSYNC
    [UInt32]          $Serial
    [CSYNCFlags]      $Flags
    [DnsRecordType[]] $TypesToProcess


    DnsCSYNCRecord() : base() { }
    DnsCSYNCRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.Flags = $binaryReader.ReadUInt16($true)

        $this.TypesToProcess = $binaryReader.ReadBitMap($this.RecordDataLength - 6)
    }

    hidden [String] RecordDataToString() {
        if ($this.TypesToProcess.Count -gt 0) {
            return '{0} {1:D} {2}' -f @(
                $this.Serial
                $this.Flags
                $this.TypesToProcess -join ' '
            )
        } else {
            return '{0} {1:D}' -f @(
                $this.Serial
                $this.Flags
            )
        }
    }
}