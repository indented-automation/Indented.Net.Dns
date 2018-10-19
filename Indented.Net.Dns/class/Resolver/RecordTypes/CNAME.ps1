class CNAME : DnsResourceRecord {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                     CNAME                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [String] $Hostname

    CNAME() { }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.Hostname = $binaryReader.ReadDnsDomainName()
    }

    [String] RecordDataToString() {
        return $this.Hostname
    }
}