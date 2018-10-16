class DnsResourceRecord {
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

    [UInt32]$TTL

    [RecordClass]$RecordClass = [RecordClass]::IN

    [Object]$RecordType = [RecordType]::Empty

    [UInt16]$RecordDataLength

    Hidden [Boolean]$IsTruncated

    DnsResourceRecord() { }

    DnsResourceRecord([EndianBinaryReader]$binaryReader) {
        $this.Name = [DnsMessage]::ReadDnsName($binaryReader)

        if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + 10)) {
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

            if ($binaryReader.BaseStream.Capacity -ge ($binaryReader.BaseStream.Position + $this.RecordDataLength)) {
                $this.ReadRecordData($binaryReader)
            } else {
                $this.IsTruncated = $true
            }
        } else {
            $this.IsTruncated = $true
        }
    }

    # Fabricates a RecordData property
    Hidden [Void] AddProperties() {
        Add-Member RecordData -MemberType ScriptProperty -Value { $this.GetRecordData() } -Force
    }
    
    # Child classes should override this method
    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $binaryReader.ReadBytes($this.RecordDataLength)
    }
    
    # Child classes should override this method
    Hidden [String] GetRecordData() {
        return
    }

    # Overrides ToString
    [String] ToString() {
        return '{0} {1} {2} {3} {4}' -f $this.Name.PadRight(29, ' '),
                                        $this.TTL.ToString().PadRight(10, ' '),
                                        $this.RecordClass.ToString().PadRight(5, ' '),
                                        $this.RecordType.ToString().PadRight(5, ' '),
                                        $this.RecordData
    }
}