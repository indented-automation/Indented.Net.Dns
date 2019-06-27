class DnsTSIGRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   ALGORITHM                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   TIMESIGNED                  |
        |                                               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     FUDGE                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    MACSIZE                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                      MAC                      /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  ORIGINALID                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     ERROR                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   OTHERSIZE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   OTHERDATA                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2845.txt
    #>

    [RecordType] $RecordType = [RecordType]::TSIG
    [String]     $Algorithm
    [DateTime]   $TimeSigned
    [Int32]      $Fudge
    [String]     $MAC
    [RCode]      $TSIGError
    [String]     $OtherData

    DnsTSIGRecord() : base() { }
    DnsTSIGRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Algorithm = $binaryReader.ReadDnsDomainName()
        $this.TimeSigned = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt48($true))
        $this.Fudge = (New-TimeSpan -Seconds ($binaryReader.ReadUInt16($true))).TotalMinutes

        $macSize = $binaryReader.ReadUInt16($true)
        $this.MAC = [BitConverter]::ToString($binaryReader.ReadBytes($macSize))

        $this.TSIGError = $binaryReader.ReadUInt16($true)

        $otherSize = $binaryReader.ReadUInt16($true)
        if ($otherSize -gt 0) {
            $this.OtherData = [BitConverter]::ToString($BinaryReader.ReadBytes($otherSize))
        }
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2} {3} {4}' -f @(
            $this.Algorithm
            $this.TimeSigned
            $this.Fudge
            $this.MAC
            $this.OtherData
        )
    }
}