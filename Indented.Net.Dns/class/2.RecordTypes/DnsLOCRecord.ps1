class DnsLOCRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        VERSION        |         SIZE          |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |       HORIZ PRE       |       VERT PRE        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   LATITUDE                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   LONGITUDE                   |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                   ALTITUDE                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1876.txt
    #>

    [Byte]            $Version
    [Decimal]         $Size
    [Decimal]         $HorizontalPrecision
    [Decimal]         $VerticalPrecision
    [AngularDistance] $Latitude
    [AngularDistance] $Longitude
    [Decimal]         $Altitude

    DnsLOCRecord() : base() { }
    DnsLOCRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Double] ConvertFromIntegerPair($byte) {
        return 0 + ('{0}e{1}' -f @(
            ($byte -band 0xF0) -shr 4
            $byte -band 0x0F
        )) / 100
    }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Version = $binaryReader.ReadByte()

        $this.Size = $this.ConvertFromIntegerPair($binaryReader.ReadByte())
        $this.HorizontalPrecision = $this.ConvertFromIntegerPair($binaryReader.ReadByte())
        $this.VerticalPrecision = $this.ConvertFromIntegerPair($binaryReader.ReadByte())

        $this.Latitude = [AngularDistance]::new($binaryReader.ReadUInt32($true), 'Latitude')
        $this.Longitude = [AngularDistance]::new($binaryReader.ReadUInt32($true), 'Longitude')
        $this.Altitude = (-10000000 + $binaryReader.ReadUInt32($true)) / 100
    }

    hidden [String] RecordDataToString() {
        return '{0} {1} {2:N2}m {3}m {4}m {5}m' -f @(
            $this.Latitude
            $this.Longitude
            $this.Altitude
            $this.Size
            $this.HorizontalPrecision
            $this.VerticalPrecision
        )
    }
}