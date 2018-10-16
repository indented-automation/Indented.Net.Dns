class A : DnsResourceRecord {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ADDRESS                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>
    
    [IPAddress]$IPAddress

    A() { }
    A([EndianBinaryReader]$binaryReader) : base($binaryReader) { }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.IPAddress = $BinaryReader.ReadIPv4Address()
    }

    Hidden [String] GetRecordData() {
        return $this.IPAddress.IPAddressToString
    }
}
