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

    [RecordType]   $RecordType = [RecordType]::CSYNC
    [UInt32]       $Serial
    [CSYNCFlags]   $Flags
    [RecordType[]] $TypesToProcess


    DnsCSYNCRecord() : base() { }
    DnsCSYNCRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.Flags = $binaryReader.ReadUInt16($true)

        $bitMapLength = $this.RecordDataLength - 6
        $bitMap = [EndianBitConverter]::ToBinary($binaryReader.ReadBytes($bitMapLength))
        $this.TypesToProcess = for ($i = 0; $i -lt $bitMap.Length; $i++) {
            if ($bitMap[$i] -eq 1) {
                [RecordType]$i
            }
        }
    }

    hidden [String] RecordDataToString() {
        $string = @(
            '{0} {1} {2}'
        ) -join "`n"
        return $string -f @(
            $this.Serial
            $this.Flags
            $this.TypesToProcess
        )
    }
}