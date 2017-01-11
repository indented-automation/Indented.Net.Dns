function NewDnsMessageHeader {
    # .SYNOPSIS
    #   Creates a new DNS message header.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                      ID                       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    QDCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ANCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    NSCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    ARCOUNT                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .INPUTS
    #   None
    # .OUTPUTS
    #   Indented.Net.Dns.MessageHeader
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/01/2017 - Chris Dent - Modernisation pass.

    [OutputType([System.Management.Automation.PSObject])]
    param( )

    $dnsMessageHeader = [PSCustomObject]@{
        ID      = [UInt16](Get-Random -Maximum ([Int32][UInt16]::MaxValue))
        QR      = [Indented.Net.Dns.QR]::Query
        OpCode  = [Indented.Net.Dns.OpCode]::Query
        Flags   = [Indented.Net.Dns.Flags]::RD
        RCode   = [Indented.Net.Dns.RCode]::NoError
        QDCount = [UInt16]1
        ANCount = [UInt16]0
        NSCount = [UInt16]0
        ARCount = [UInt16]0
    } | Add-Member -TypeName 'Indented.Net.Dns.Message.Header' -PassThru

    # Method: ToByte
    $dnsMessageHeader | Add-Member ToByte -MemberType ScriptMethod -Value {
        $bytes = New-Object System.Collections.Generic.List[Byte]

        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($this.ID, $true))

        # The UInt16 value which comprises QR, OpCode, Flags (including Z) and RCode.
        $flags = [UInt16]([UInt16]$this.QR -bor [UInt16]$this.OpCode -bor [UInt16]$this.Flags -bor [UInt16]$this.RCode)
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($flags, $true))

        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($this.QDCount, $true))
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($this.ANCount, $true))
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($this.NSCount, $true))
        $bytes.AddRange([Indented.EndianBitConverter]::GetBytes($this.ARCount, $true))

        return ,$bytes.ToArray()
    }

    # Method: ToString
    $DnsMessageHeader | Add-Member ToString -MemberType ScriptMethod -Force -Value {
        return 'ID: {0} QR: {1} OpCode: {2} RCode: {3} Flags: {4} Query: {5} Answer: {6} Authority: {7} Additional: {8}' -f
            $this.ID.ToString(),
            $this.QR.ToString().ToUpper(),
            $this.OpCode.ToString().ToUpper(),
            $this.RCode.ToString().ToUpper(),
            $this.Flags,
            $this.QDCount,
            $this.ANCount,
            $this.NSCount,
            $this.ARCount
    }

    return $dnsMessageHeader
}