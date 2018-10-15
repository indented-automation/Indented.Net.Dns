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

    [RecordClass]$RecordClass

    DnsQuestion() { }

    DnsQuestion([String]$recordName, [RecordType]$type, [RecordClass]$class) {
        $this.Name = $recordName
        $this.RecordType = $type
        $this.RecordClass = $class
    }

    [Byte[]] GetBytes() {
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