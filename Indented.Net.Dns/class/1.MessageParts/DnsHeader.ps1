class DnsHeader {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                      ID                       |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    QDCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ANCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    NSCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |                    ARCOUNT                    |
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>

    [ushort]      $ID
    [QR]          $QR
    [OpCode]      $OpCode
    [HeaderFlags] $Flags
    [RCode]       $RCode
    [ushort]      $QuestionCount
    [ushort]      $AnswerCount
    [ushort]      $AuthorityCount
    [ushort]      $AdditionalCount

    DnsHeader() { }

    DnsHeader(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.ID = $binaryReader.ReadUInt16($true)

        $value = $binaryReader.ReadUInt16($true)
        $this.QR = $value -band 0x8000
        $this.OpCode = ($value -band 0x7800) -shr 11
        $this.Flags = $value -band 0x07B0
        $this.RCode = $value -band 0x000F

        $this.QuestionCount = $binaryReader.ReadUInt16($true)
        $this.AnswerCount = $binaryReader.ReadUInt16($true)
        $this.AuthorityCount = $binaryReader.ReadUInt16($true)
        $this.AdditionalCount = $binaryReader.ReadUInt16($true)
    }

    DnsHeader(
        [bool] $recursionDesired,
        [ushort]  $questionCount
    ) {
        $this.ID = Get-Random -Minimum 0 -Maximum ([ushort]::MaxValue + 1)

        if ($recursionDesired) {
            $this.Flags = [HeaderFlags]::RD
        }
        $this.QuestionCount = $questionCount
    }

    [byte[]] ToByteArray() {
        $bytes = [byte[]]::new(12)

        $bytes[0], $bytes[1] = [EndianBitConverter]::GetBytes($this.ID, $true)

        # QR, Flags, OpCode and RCode
        [ushort]$value = $this.QR -bor
            ([ushort]$this.OpCode -shl 11) -bor
            $this.Flags -bor
            $this.RCode
        $bytes[2], $bytes[3] = [EndianBitConverter]::GetBytes($value, $true)

        $bytes[4], $bytes[5] = [EndianBitConverter]::GetBytes($this.QuestionCount, $true)
        $bytes[6], $bytes[7] = [EndianBitConverter]::GetBytes($this.AnswerCount, $true)
        $bytes[8], $bytes[9] = [EndianBitConverter]::GetBytes($this.AuthorityCount, $true)
        $bytes[10], $bytes[11] = [EndianBitConverter]::GetBytes($this.AdditionalCount, $true)

        return $bytes
    }

    [string] ToString() {
        return 'ID: {0} OpCode: {1} RCode: {2} Flags: {3} Query: {4} Answer: {5} Authority: {6} Additional: {7}' -f @(
            $this.ID
            $this.OpCode.ToString().ToUpper()
            $this.RCode.ToString().ToUpper()
            $this.Flags.ToString().ToUpper()
            $this.QuestionCount
            $this.AnswerCount
            $this.AuthorityCount
            $this.AdditionalCount
        )
    }
}
