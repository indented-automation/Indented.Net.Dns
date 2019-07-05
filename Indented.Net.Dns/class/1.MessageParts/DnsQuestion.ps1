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

    [String]        $Name
    [DnsRecordType] $RecordType
    [Object]        $RecordClass

    DnsQuestion() { }

    DnsQuestion(
        [String]      $recordName,
        [RecordType]  $type,
        [RecordClass] $class
    ) {
        $this.Name = $recordName
        $this.RecordType = $type
        $this.RecordClass = $class
    }

    DnsQuestion(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.Name = $binaryReader.ReadDnsDomainName()
        $this.RecordType = [DnsRecordType]$binaryReader.ReadUInt16($true)

        if ($this.RecordType -eq 'OPT') {
            $this.RecordClass = $binaryReader.ReadUInt16($true)
        } else {
            $this.RecordClass = [RecordClass]$binaryReader.ReadUInt16($true)
        }
    }

    hidden [Byte[]] ToByteArray() {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.Name))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordType, $true))
        $bytes.AddRange([EndianBitConverter]::GetBytes([UInt16]$this.RecordClass, $true))

        return $bytes.ToArray()
    }

    [String] ToString() {
        return '{0,-29}            {1,-5} {2,-5}' -f @(
            $this.Name
            $this.RecordClass
            $this.RecordType
        )
    }
}