class A : DnsResourceRecord {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ADDRESS                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [IPAddress] $IPAddress

    A() { }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.IPAddress = $BinaryReader.ReadIPv4Address()
    }

    [String] RecordDataToString() {
        return $this.IPAddress.IPAddressToString
    }
}
