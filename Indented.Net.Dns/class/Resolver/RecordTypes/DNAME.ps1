class DNAME : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                     TARGET                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2672.txt
    #>

    [String] $Target

    DNAME() { }

    [Void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Target = $binaryReader.ReadDnsDomainName()
    }

    [String] RecordDataToString() {
        return $this.Target
    }
}