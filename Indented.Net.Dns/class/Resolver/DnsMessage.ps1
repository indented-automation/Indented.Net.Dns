using namespace System.Collections.Generic
using namespace System.Text

class DnsMessage {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                                               /
       /                    HEADER                     /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                                               /
       /                   QUESTION                    /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                                               /
       /                   AUTHORITY                   /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [DnsHeader]$Header = [DnsHeader]::new()
    [DnsQuestion]$Question = [DnsQuestion]::new()
    [List[ResourceRecord]]$Answer = [List[ResourceRecord]]::new()
    [List[ResourceRecord]]$Authority = [List[ResourceRecord]]::new()
    [List[ResourceRecord]]$Additional = [List[ResourceRecord]]::new()

    [String]$Server = ""

    [Int]$Size = 0

    [Int]$TimeTaken = 0

    # Constructors

    DnsMessage() { }

    DnsMessage([String]$name, [RecordType]$recordType, [RecordClass]$recordClass) {
        $this.Question.Add(
            [DnsQuestion]::new($name, $recordType, $recordClass)
        )
    }

    # Methods

    Hidden [String] RecordSetToString([IEnumerable]$resourceRecords) {
        $string = [StringBuilder]::new()
        foreach ($resourceRecord in $resourceRecords) {
            $string.AppendLine($resourceRecord.ToString())
        }
        return $string
    }

    [String] QuestionToString() {
        return $this.RecordSetToString($this.Question)
    }

    [String] AnswerToString() {
        return $this.RecordSetToString($this.Answer)
    }

    [String] AuthorityToString() {
        return $this.RecordSetToString($this.Authority)
    }

    [String] AdditionalToString() {
        return $this.RecordSetToString($this.Additional)
    }

    [Void] SetEDnsBufferSize() {
        $this.SetEDnsBufferSize(4096)
    }

    [Void] SetEDnsBufferSize([UInt16]$EDnsBufferSize) {
        $this.Header.ARCount = 1
        $this.Additional.Add([OPTRecord]@{
            MaximumPayloadSize = $EDnsBufferSize
        })
    }

    [Void] SetAcceptDnsSec() {
        $this.Header.RawFlags = $this.Header.RawFlags -bor [HeaderFlags]::AD
    }

    [Byte[]] GetBytes() {
        return $this.GetBytes($false)
    }

    [Byte[]] GetBytes([Boolean]$tcp) {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange($this.Header.GetBytes())
        $bytes.AddRange($this.Question.GetBytes())

        if ($this.Header.NSCount -gt 0) {
            foreach ($resourceRecord in $this.Authority) {
                $bytes.AddRange($resourceRecord.GetBytes())                
            }
        }
        if ($this.Header.ARCount -gt 0) {
            foreach ($resourceRecord in $this.Additional) {
                $bytes.AddRange($resourceRecord.GetBytes())
            }
        }

        if ($tcp) {
            # A value must be added to denote payload length when using a stream-based protocol.
            $length = [BitConverter]::GetBytes([UInt16]$bytes.Count)
            [Array]::Reverse($length)
            $bytes.InsertRange(0, $length)
        }

        return $bytes.ToArray()
    }
}