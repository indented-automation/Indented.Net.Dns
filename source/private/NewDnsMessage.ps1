function NewDnsMessage {
    # .SYNOPSIS
    #   Create a new DNS message object.
    # .DESCRIPTION
    #   Authority is added when attempting an incremental zone transfer.
    #
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
    #
    # .OUTPUTS
    #   Indented.Net.Dns.Message
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([System.Management.Automation.PSObject])]
    param(
        [String]$Name = "",

        [Indented.Net.Dns.RecordType]$RecordType = [Indented.Net.Dns.RecordType]::ANY,

        [Indented.Net.Dns.RecordClass]$RecordClass = [Indented.Net.Dns.RecordClass]::IN,

        [UInt32]$SerialNumber
    )

    $dnsMessage = [PSCustomObject]@{
        Header             = NewDnsMessageHeader
        Question           = NewDnsMessageQuestion -Name $Name -RecordType $RecordType -RecordClass $RecordClass
        Answer             = @()
        Authority          = @()
        Additional         = @()
        Server             = ""
        Size               = 0
        TimeTaken          = 0
    } | Add-Member -TypeName 'Indented.Net.Dns.Message' -PassThru

    if ($SerialNumber -and $RecordType -eq [Indented.Net.Dns.RecordType]::IXFR) {
        $dnsMessage.Header.NSCount = [UInt16]1
        $dnsMessage.Authority = NewDnsSOARecord -Name $Name -SerialNumber $SerialNumber
    }

    # Property: QuestionToString
    $dnsMessage | Add-Member QuestionToString -MemberType ScriptProperty -Value {
        return [String]::Join("`n", $this.Question)
    }

    # Property: AnswerToString
    $dnsMessage | Add-Member AnswerToString -MemberType ScriptProperty -Value {
        return [String]::Join("`n", $this.Answer)
    }

    # Property: AuthorityToString
    $dnsMessage | Add-Member AuthorityToString -MemberType ScriptProperty -Value {
        return [String]::Join("`n", $this.Authority)
    }

    # Property: AdditionalToString
    $dnsMessage | Add-Member AdditionalToString -MemberType ScriptProperty -Value {
        return [String]::Join("`n", $this.Additional)
    }

    # Method: SetEDnsBufferSize
    $dnsMessage | Add-Member SetEDnsBufferSize -MemberType ScriptMethod -Value {
        param(
            [UInt16]$EDnsBufferSize = 4096
        )

        $this.Header.ARCount = [UInt16]1
        $this.Additional += NewDnsOPTRecord
        $this.Additional[0].MaximumPayloadSize = $EDnsBufferSize
    }

    # Method: SetAcceptDnsSec
    $dnsMessage | Add-Member SetAcceptDnsSec -MemberType ScriptMethod -Value {
        $this.Header.Flags = [Indented.Net.Dns.Flags]([UInt16]$this.Header.Flags -bxor [UInt16][Indented.Net.Dns.Flags]::AD)
    }

    # Method: ToByte
    $dnsMessage | Add-Member ToByte -MemberType ScriptMethod -Value {
        param(
            [System.Net.Sockets.ProtocolType]$ProtocolType = [System.Net.Sockets.ProtocolType]::Udp
        )

        $bytes = New-Object System.Collections.Generic.List[Byte]

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

        if ($ProtocolType -eq [System.Net.Sockets.ProtocolType]::Tcp) {
            # A value must be added to denote payload length when using a stream-based protocol.
            $length = [BitConverter]::GetBytes([UInt16]$bytes.Count)
            [Array]::Reverse($length)
            $bytes.InsertRange(0, $length)
        }

        return ,$bytes.ToArray()
    }

    return $dnsMessage
}