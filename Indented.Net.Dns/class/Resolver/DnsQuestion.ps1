using namespace System.Collections.Generic

class DnsQuestion {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                     QNAME                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                     QTYPE                     |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                     QCLASS                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [String]$Name

    [RecordType]$RecordType

    [Object]$RecordClass

    DnsQuestion() { }

    DnsQuestion([String]$recordName, [RecordType]$type, [RecordClass]$class) {
        $this.Name = $recordName
        $this.RecordType = $type
        $this.RecordClass = $class
    }

    DnsQuestion([EndianBinaryReader]$binaryReader) {
        $this.Name = $binaryReader.ReadDnsDomainName()
        $this.RecordType = [RecordType]$BinaryReader.ReadUInt16($true)
    
        if ($this.RecordType -eq [RecordType]::OPT) {
            $this.RecordClass = $BinaryReader.ReadUInt16($true)
        } else {
            $this.RecordClass = [RecordClass]$BinaryReader.ReadUInt16($true)
        }
    }

    [Byte[]] ToByteArray() {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange((ConvertFromDnsDomainName $this.Name))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordType, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordClass, $true))

        return $bytes.ToArray()
    }

    [String] ToString() {
        return '{0}            {1} {2}' -f
            $this.Name.PadRight(29, ' '),
            $this.RecordClass.ToString().PadRight(5, ' '),
            $this.RecordType.ToString().PadRight(5, ' ')
    }
}