class DnsL64Record : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  PREFERENCE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    LOCATOR                    |
        |                                               |
        |                                               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        https://www.ietf.org/rfc/rfc6742.txt
    #>

    [UInt16] $Preference
    [String] $Locator

    DnsL64Record() : base() { }
    DnsL64Record(
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

        $bytes = $binaryReader.ReadBytes(8)
        $address = for ($i = 0; $i -lt $bytes.Count; $i += 2) {
            ('{0:x2}{1:x2}' -f $bytes[$i], $bytes[$i + 1]).TrimStart('0')
        }
        $this.Locator = $address -join ':'
    }

    hidden [String] RecordDataToString() {
        return '{0} {1}' -f @(
            $this.Preference
            $this.Locator
        )
    }
}