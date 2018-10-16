class DnsHeader {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      ID                       |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    QDCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ANCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    NSCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ARCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [UInt16]$ID

    [UInt16]$QDCount
    
    [UInt16]$ANCount

    [UInt16]$NSCount

    [UInt16]$ARCount

    Hidden [UInt16]$RawFlags

    DnsHeader() {
        $this.AddProperties()
    }

    DnsHeader([EndianBinaryReader]$binaryReader) {
        $this.AddProperties()

        $this.ID = $binaryReader.ReadUInt16($true)
        $this.RawFlags = $binaryReader.ReadUInt16($true)
        $this.QDCount = $binaryReader.ReadUInt16($true)
        $this.ANCount = $binaryReader.ReadUInt16($true)
        $this.NSCount = $binaryReader.ReadUInt16($true)
        $this.ARCount = $binaryReader.ReadUInt16($true)
    }

    Hidden [Void] AddProperties() {
        $this | Add-Member QR -MemberType ScriptProperty -Value { [QR]($this.RawFlags -band 0x8000) }
        $this | Add-Member OpCode -MemberType ScriptProperty -Value { [OpCode]($this.RawFlags -band 0x7800) }
        $this | Add-Member Flags -MemberType ScriptProperty -Value { [HeaderFlags]($this.RawFlags -band 0x8000) }
        $this | Add-Member RCode -MemberType ScriptProperty -Value { [RCode]($this.RawFlags -band 0x8000) }
    }

    [Byte[]] ToByteArray() {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.ID, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RawFlags, $true))

        return $bytes.ToArray()
    }
}