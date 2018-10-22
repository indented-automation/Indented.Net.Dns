using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Text
using namespace System.IO

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

    [DnsHeader]           $Header
    [DnsQuestion[]]       $Question
    [DnsResourceRecord[]] $Answer
    [DnsResourceRecord[]] $Authority
    [DnsResourceRecord[]] $Additional
    [Int]                 $Size
    [Int]                 $TimeTaken

    # Constructors

    DnsMessage() { }

    DnsMessage(
        [String]      $name,
        [RecordType]  $recordType,
        [RecordClass] $recordClass
    ) {
        $this.Question = [DnsQuestion]::new($name, $recordType, $recordClass)
    }

    DnsMessage([Byte[]]$message) {
        $binaryReader = [EndianBinaryReader][MemoryStream]$message
        $this.Size = $message.Length

        $this.Header = [DnsHeader]$binaryReader

        $this.Question = for ($i = 0; $i -lt $this.Header.QuestionCount; $i++) {
            [DnsQuestion]$binaryReader
        }
        $this.Answer = for ($i = 0; $i -lt $this.Header.AnswerCount; $i++) {
            [DnsResourceRecord]::Parse($binaryReader)
        }
        $this.Authority = for ($i = 0; $i -lt $this.Header.AuthorityCount; $i++) {
            [DnsResourceRecord]::Parse($binaryReader)
        }
        $this.Additional = for ($i = 0; $i -lt $this.Header.AdditionalCount; $i++) {
            [DnsResourceRecord]::Parse($binaryReader)
        }
    }

    # Methods

    Hidden [String] RecordSetToString(
        [IEnumerable] $resourceRecords
    ) {
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
        $this.Header.AdditionalCount = 1
        $this.Additional = [OPT]@{
            MaximumPayloadSize = $EDnsBufferSize
        }
    }

    [Void] SetAcceptDnsSec() {
        $this.Header.Flags = $this.Header.Flags -bor [HeaderFlags]::AD
    }

    [Byte[]] GetBytes() {
        return $this.GetBytes($false)
    }

    [Byte[]] ToByteArray(
        [Boolean] $tcp
    ) {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange($this.Header.ToByteArray())
        $bytes.AddRange($this.Question.ToByteArray())

        if ($this.Header.AuthorityCount -gt 0) {
            foreach ($resourceRecord in $this.Authority) {
                $bytes.AddRange($resourceRecord.ToByteArray())
            }
        }
        if ($this.Header.AdditionalCount -gt 0) {
            foreach ($resourceRecord in $this.Additional) {
                $bytes.AddRange($resourceRecord.ToByteArray())
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