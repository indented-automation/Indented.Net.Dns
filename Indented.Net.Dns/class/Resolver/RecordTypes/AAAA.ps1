class AAAA : DnsResourceRecord {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ADDRESS                    |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       |                                               |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [IPAddress] $IPAddress

    AAAA() { }
    AAAA([DnsResourceRecord]$resourceRecord) {
        foreach ($name in $resourceRecord.PSObject.Properties.Name) {
            $this.$name = $resourceRecord.$name
        }
    }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.IPAddress = $binaryReader.ReadIPv6Address()
    }

    [String] RecordDataToString() {
        return $this.IPAddress.IPAddressToString
    }
}
