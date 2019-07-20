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
        /                    QUESTION                   /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                                               /
        /                     ANSWER                    /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                                               /
        /                    AUTHORITY                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                                               /
        /                    ADDITIONAL                 /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [DnsHeader]           $Header
    [DnsQuestion[]]       $Question
    [DnsResourceRecord[]] $Answer
    [DnsResourceRecord[]] $Authority
    [DnsResourceRecord[]] $Additional
    [Int]                 $Size
    [Int64]               $TimeTaken
    [String]              $ComputerName

    DnsMessage() { }

    DnsMessage(
        [String]      $name,
        [RecordType]  $recordType
    ) {
        $this.Header = [DnsHeader]::new($true, 1)
        $this.Question = [DnsQuestion]::new($name, $recordType, 'IN')
    }

    DnsMessage(
        [String]      $name,
        [RecordType]  $recordType,
        [RecordClass] $recordClass
    ) {
        $this.Header = [DnsHeader]::new($true, 1)
        $this.Question = [DnsQuestion]::new($name, $recordType, $recordClass)
    }

    DnsMessage(
        [String]      $name,
        [RecordType]  $recordType,
        [RecordClass] $recordClass,
        [UInt32]      $Serial
    ) {
        $this.Header = [DnsHeader]::new($true, 1)
        $this.Question = [DnsQuestion]::new($name, $recordType, $recordClass)

        $this.Header.AuthorityCount = 1
        $this.Authority = [DnsSOARecord]@{ Serial = $Serial }
    }

    DnsMessage(
        [Byte[]] $message
    ) {
        $this.ReadDnsMessage($message, $true)
    }

    DnsMessage(
        [Byte[]]  $message,
        [Boolean] $convertIdnToUnicode
    ) {
        $this.ReadDnsMessage($message, $convertIdnToUnicode)
    }

    hidden [Void] ReadDnsMessage(
        [Byte[]]  $message,
        [Boolean] $convertIdnToUnicode
    ) {
        $binaryReader = [EndianBinaryReader][MemoryStream]$message
        $binaryReader.ConvertIdnToUnicode = $convertIdnToUnicode

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

    hidden [String] RecordSetToString(
        [DnsResourceRecord[]] $resourceRecords
    ) {
        if ($resourceRecords.Count -gt 0) {
            $string = [StringBuilder]::new()
            foreach ($resourceRecord in $resourceRecords) {
                if ($resourceRecord.RecordType -ne [RecordType]::OPT) {
                    $string.AppendLine($resourceRecord.ToString())
                }
            }
            return $string.ToString().TrimEnd()
        }
        return ''
    }

    [String] QuestionToString() {
        $string = [StringBuilder]::new()
        foreach ($question in $this.Question) {
            $string.AppendLine($question.ToString())
        }
        return $string.ToString().TrimEnd()
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
        $this.Additional = [DnsOPTRecord]@{
            MaximumPayloadSize = $EDnsBufferSize
            Z                  = [EDnsDNSSECOK]::DO
        }
    }

    [Void] SetAcceptDnsSec() {
        $this.Header.Flags = $this.Header.Flags -bor [HeaderFlags]::AD
    }

    [Void] DisableRecursion() {
        $this.Header.Flags = [UInt16]$this.Header.Flags -bxor [UInt16][HeaderFlags]::RD
    }

    [Byte[]] ToByteArray() {
        return $this.ToByteArray($false, $true)
    }

    [Byte[]] ToByteArray(
        [Boolean] $useCompressedNames
    ) {
        return $this.ToByteArray($false, $useCompressedNames)
    }

    [Byte[]] ToByteArray(
        [Boolean] $tcp,
        [Boolean] $useCompressedNames
    ) {
        $bytes = [List[Byte]]::new()

        $bytes.AddRange($this.Header.ToByteArray())
        $bytes.AddRange([Byte[]]$this.Question.ToByteArray())

        if ($this.Header.AuthorityCount -gt 0) {
            foreach ($resourceRecord in $this.Authority) {
                $bytes.AddRange($resourceRecord.ToByteArray($useCompressedNames))
            }
        }
        if ($this.Header.AdditionalCount -gt 0) {
            foreach ($resourceRecord in $this.Additional) {
                $bytes.AddRange($resourceRecord.ToByteArray())
            }
        }

        if ($tcp) {
            $length = [BitConverter]::GetBytes([UInt16]$bytes.Count)
            [Array]::Reverse($length)
            $bytes.InsertRange(0, $length)
        }

        return $bytes.ToArray()
    }
}