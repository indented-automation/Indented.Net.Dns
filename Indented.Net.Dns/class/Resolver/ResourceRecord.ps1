class ResourceRecord {
    <#
                                      1  1  1  1  1  1
        0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                      NAME                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      TYPE                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                     CLASS                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      TTL                      |
       |                                               |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                   RDLENGTH                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
       /                     RDATA                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+    
    #>

    [String]$Name

    [UInt32]$TTL = [UInt32]0

    [RecordClass]$RecordClass = [RecordClass]::IN

    [Object]$RecordType = [RecordType]::Empty

    [UInt16]$RecordDataLength = 0

    [String]$RecordData = ''

    ResourceRecord() { }

    ResourceRecord([EndianBinaryReader]$binaryReader) {
        $resourceRecord.Name = [DnsMessage]::ReadDnsName($binaryReader)

        $type = $binaryReader.ReadUInt16($true)
        if ([Enum]::IsDefined([RecordType], $type)) {
            $this.RecordType = [RecordType]$type
        } else {
            $this.RecordType = 'UNKNOWN ({0})' -f $type
        }

        if ($this.RecordType -eq [RecordType]::OPT) {
            $this.RecordClass = $binaryReader.ReadUInt16($true)
        } else {
            $this.RecordClass = [RecordClass]$binaryReader.ReadUInt16($true)
        }
    
        $this.TTL = $binaryReader.ReadUInt32($true)
        $this.RecordDataLength = $binaryReader.ReadUInt16($true)
    }

    static [Boolean] IsTruncated([EndianBinaryReader]$binaryReader) {
        $binaryReader.SetMarker()
        [DnsMessage]::ReadDnsName($binaryReader)

        if ($binaryReader.BaseStream.Capacity -lt ($binaryReader.BaseStream.Position + 10)) {
            return $true
        }
        $binaryReader.ReadBytes(8)
        $rdLength = $binaryReader.ReadUInt16($true)

        if ($binaryReader.BaseStream.Capacity -lt ($binaryReader.BaseStream.Position + $rdLength)) {
            return $true
        }

        # Return to marker

        return $false
    }

    [String] ToString() {
        return '{0} {1} {2} {3} {4}' -f $this.Name.PadRight(29, ' '),
                                        $this.TTL.ToString().PadRight(10, ' '),
                                        $this.RecordClass.ToString().PadRight(5, ' '),
                                        $this.RecordType.ToString().PadRight(5, ' '),
                                        $this.RecordData
    }
}