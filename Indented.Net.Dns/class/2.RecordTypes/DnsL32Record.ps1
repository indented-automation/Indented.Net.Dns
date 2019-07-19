class DnsL32Record : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    LOCATOR                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://www.ietf.org/rfc/rfc6742.txt
    #>

    [UInt16] $Preference
    [String] $Locator

    DnsL32Record() : base() { }
    DnsL32Record(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Preference = $binaryReader.ReadUInt16($true)
        $this.Locator = $binaryReader.ReadIPAddress()
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference
            $this.Locator
        )
    }
}