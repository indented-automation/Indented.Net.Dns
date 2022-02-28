class DnsDOARecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 DOA-ENTERPRISE                |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    DOA-TYPE                   |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |     DOA-LOCATION      |                       /
        +--+--+--+--+--+--+--+--+                       /
        /                 DOA-MEDIA-TYPE                /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    DOA-DATA                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://tools.ietf.org/html/draft-durand-doa-over-dns-03

        DOA Enterprise values are defined by:

        https://www.iana.org/assignments/enterprise-numbers/enterprise-numbers
    #>

    [UInt32]      $Enterprise
    [UInt32]      $Type
    [DOALocation] $Location
    [string]      $MediaType
    [string]      $Data

    DnsDOARecord() : base() { }
    DnsDOARecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Enterprise = $binaryReader.ReadUInt32($true)
        $this.Type = $binaryReader.ReadUInt32($true)
        $this.Location = $binaryReader.ReadByte()

        $length = 0
        $this.MediaType = $binaryReader.ReadDnsCharacterString([ref]$length)

        $length = $this.RecordDataLength - 9 - $length
        $this.Data = [Convert]::ToBase64String($binaryReader.ReadBytes($length))
    }

    hidden [string] RecordDataToString() {
        return '{0} {1} {2:D} "{3}" {4}' -f @(
            $this.Enterprise
            $this.Type
            $this.Location
            $this.MediaType
            $this.Data
        )
    }
}
