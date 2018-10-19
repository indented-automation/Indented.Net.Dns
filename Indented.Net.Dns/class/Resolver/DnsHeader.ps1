using namespace System.Collections.Generic

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

    [UInt16]      $ID
    [QR]          $QR
    [OpCode]      $OpCode
    [HeaderFlags] $Flags
    [RCode]       $RCode
    [UInt16]      $QuestionCount
    [UInt16]      $AnswerCount
    [UInt16]      $AuthorityCount
    [UInt16]      $AdditionalCount

    DnsHeader() { }

    DnsHeader([EndianBinaryReader]$binaryReader) {
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

    DnsHeader([Boolean]$recursionDesired, [UInt16]$questionCount) {
        if ($recursionDesired) {
            $this.Flags = $this.Flags -bor ([HeaderFlags]::RD -shr 8)
        }
        $this.QDCount = $questionCount
    }

    [Byte[]] ToByteArray() {
        $bytes = [Byte[]]::new(12)

        $bytes[0], $bytes[1] = [EndianBitConverter]::GetBytes($this.ID, $false)

        # QR, Flags, OpCode and RCode
        [UInt16]$value = $this.QR -bor
            ([UInt16]$this.OpCode -shl 11) -bor
            $this.Flags -bor
            $this.RCode
        $bytes[2], $bytes[3] = [EndianBitConverter]::GetBytes($value, $false)

        $bytes[4], $bytes[5] = [EndianBitConverter]::GetBytes($this.QDCount, $false)

        $bytes[6], $bytes[7] = [EndianBitConverter]::GetBytes($this.ANCount, $false)

        $bytes[8], $bytes[9] = [EndianBitConverter]::GetBytes($this.NSCOUNT, $false)

        $bytes[10], $bytes[11] = [EndianBitConverter]::GetBytes($this.ARCOUNT, $false)

        return $bytes
    }

    [String] ToString() {
        return 'ID: {0} OpCode: {1} RCode: {2} Flags: {3} Query: {4} Answer: {5} Authority: {6} Additional: {7}' -f
            $this.ID,
            $this.OpCode.ToString().ToUpper(),
            $this.RCode.ToString().ToUpper(),
            $this.Flags,
            $this.QuestionCount,
            $this.AnswerCount,
            $this.AuthorityCount,
            $this.AdditionalCount
    }
}