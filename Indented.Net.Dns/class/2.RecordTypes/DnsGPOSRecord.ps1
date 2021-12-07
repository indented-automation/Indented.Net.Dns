class DnsGPOSRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   LONGITUDE                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   LATITUDE                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                   ALTITUDE                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc1712.txt
    #>

    [string] $Longitude
    [string] $Latitude
    [string] $Altitude

    DnsGPOSRecord() : base() { }
    DnsGPOSRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Longitude = $binaryReader.ReadDnsCharacterString()
        $this.Latitude = $binaryReader.ReadDnsCharacterString()
        $this.Altitude = $binaryReader.ReadDnsCharacterString()
    }

    hidden [string] RecordDataToString() {
        return '"{0}" "{1}" "{2}"' -f @(
            $this.Longitude
            $this.Latitude
            $this.Altitude
        )
    }
}
