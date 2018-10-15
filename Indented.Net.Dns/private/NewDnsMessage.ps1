using namespace Indented.Net.Dns
using namespace System.Net.Sockets

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
    # .NOTES
    #   Change log:
    #     11/01/2017 - Chris Dent - Modernisation pass.

    [OutputType('Indented.Net.Dns.Message')]
    param(
        # The name passed into the question.
        [String]$Name = "",

        # The record type passed into the question.
        [RecordType]$RecordType = 'ANY',

        # The record class passed into the question.
        [RecordClass]$RecordClass = 'IN',

        # An optional serial number, used for IXFR queries.
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

    if ($SerialNumber -and $RecordType -eq [RecordType]::IXFR) {
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
        $this.Header.Flags = [HeaderFlags]([UInt16]$this.Header.Flags -bxor [UInt16][HeaderFlags]::AD)
    }

    # Method: ToByte
    $dnsMessage | Add-Member ToByte -MemberType ScriptMethod -Value {
        param(
            [ProtocolType]$ProtocolType = 'Udp'
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

        if ($ProtocolType -eq [ProtocolType]::Tcp) {
            # A value must be added to denote payload length when using a stream-based protocol.
            $length = [BitConverter]::GetBytes([UInt16]$bytes.Count)
            [Array]::Reverse($length)
            $bytes.InsertRange(0, $length)
        }

        return ,$bytes.ToArray()
    }

    return $dnsMessage
}