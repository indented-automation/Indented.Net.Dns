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

    [string]   $Algorithm
    [DateTime] $TimeSigned
    [ushort]   $Fudge
    [string]   $MAC
    [ushort]   $OriginalID
    [RCode]    $TSIGError
    [string]   $OtherData

    DnsTSIGRecord() : base() { }
    DnsTSIGRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Algorithm = $binaryReader.ReadDnsDomainName()
        $this.TimeSigned = (Get-Date "01/01/1970").AddSeconds($binaryReader.ReadUInt48($true))
        $this.Fudge = $binaryReader.ReadUInt16($true)

        $macSize = $binaryReader.ReadUInt16($true)
        $this.MAC =  [EndianBitConverter]::ToHexadecimal($binaryReader.ReadBytes($macSize))

        $this.OriginalID = $binaryReader.ReadUInt16($true)
        $this.TSIGError = $binaryReader.ReadUInt16($true)

        $otherSize = $binaryReader.ReadUInt16($true)

        if ($otherSize -gt 0) {
            $this.OtherData = [EndianBitConverter]::ToHexadecimal($BinaryReader.ReadBytes($otherSize))
        }
    }

    hidden [string] RecordDataToString() {
        return '{0} {1:yyyyMMddHHmmss} {2} {3} {4} {5:D} {6}' -f @(
            $this.Algorithm
            $this.TimeSigned
            $this.Fudge
            $this.MAC
            $this.OriginalID
            $this.TSIGError
            $this.OtherData
        )
    }
}
