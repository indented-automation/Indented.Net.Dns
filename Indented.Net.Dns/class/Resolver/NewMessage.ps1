class DnsMessage {
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                                               /
    #    /                    HEADER                     /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                                               /
    #    /                   QUESTION                    /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                                               /
    #    /                   AUTHORITY                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

    [DnsHeader]$Header = [DnsHeader]::new()
    [DnsQuestion]$Question = [DnsQuestion]@{
        Name        = $Name
        RecordType  = $RecordType
        RecordClass = $RecordClass
    }
    [List[ResourceRecord]]$Answer = [List[ResourceRecord]]::new()
    [List[ResourceRecord]]$Authority = [List[ResourceRecord]]::new()
    [List[ResourceRecord]]$Additional = [List[ResourceRecord]]::new()

    [String]$Server = ""

    [Int]$Size = 0

    [Int]$TimeTaken = 0

    # Constructors

    DnsMessage() 
    Question           = NewDnsMessageQuestion -Name $Name -RecordType $RecordType -RecordClass $RecordClass


    # Methods

    Hidden [String] RecordSetToString([IEnumerable]$resourceRecords) {
        $string = [StringBuilder]::new()
        foreach ($resourceRecord in $resourceRecords) {
            $string.AppendLine($record.ToString())
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
        $this.Header.ARCount = [UInt16]1
        $this.Additional.Add([OPTRecord]::new())
        $this.Additional[0].MaximumPayloadSize = $EDnsBufferSize
    }

    [Void] SetAcceptDnsSec() {
        $this.Header.Flags = [HeaderFlags]([UInt16]$this.Header.Flags -bxor [UInt16][HeaderFlags]::AD)
    }

    [Byte[]] ToByte() {
        return $this.ToByte($false)
    }

    [Byte[]] ToByte([Boolean]$tcp) {
        $bytes = [List[Byte]]

        $bytes.AddRange($this.Header.ToByte())
        $bytes.AddRange($this.Question.ToByte())

        if ($this.Header.NSCount -gt 0) {
            foreach ($resourceRecord in $this.Authority) {
                $bytes.AddRange($resourceRecord.ToByte())                
            }
        }
        if ($this.Header.ARCount -gt 0) {
            foreach ($resourceRecord in $this.Additional) {
                $bytes.AddRange($resourceRecord.ToByte())
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