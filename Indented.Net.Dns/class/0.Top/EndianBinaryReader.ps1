using namespace System.Collections.Generic
using namespace System.Globalization
using namespace System.IO
using namespace System.Text

class EndianBinaryReader : BinaryReader {
    [bool] $ConvertIdnToUnicode = $true

    hidden [IdnMapping] $idnMapping = [IdnMapping]::new()

    EndianBinaryReader([Stream]$BaseStream) : base($BaseStream) { }

    [UInt16] ReadUInt16(
        [bool] $isBigEndian
    ) {
        if ($isBigEndian) {
            return [UInt16](([UInt16]$this.ReadByte() -shl 8) -bor $this.ReadByte())
        } else {
            return $this.ReadUInt16()
        }
    }

    [UInt32] ReadUInt32(
        [bool] $isBigEndian
    ) {
        if ($isBigEndian) {
            return [UInt32](
                ([UInt32]$this.ReadByte() -shl 24) -bor
                ([UInt32]$this.ReadByte() -shl 16) -bor
                ([UInt32]$this.ReadByte() -shl 8) -bor
                $this.ReadByte())
        } else {
            return $this.ReadUInt32()
        }
    }

    [UInt64] ReadUInt48() {
        return $this.ReadUInt48($false)
    }

    [UInt64] ReadUInt48(
        [bool] $isBigEndian
    ) {
        if ($isBigEndian) {
            return [UInt64](
                ([UInt64]$this.ReadByte() -shl 40) -bor
                ([UInt64]$this.ReadByte() -shl 32) -bor
                ([UInt64]$this.ReadByte() -shl 24) -bor
                ([UInt64]$this.ReadByte() -shl 16) -bor
                ([UInt64]$this.ReadByte() -shl 8) -bor
                $this.ReadByte())
        } else {
            return [UInt64]($this.ReadByte() -bor
                ([UInt64]$this.ReadByte() -shl 8) -bor
                ([UInt64]$this.ReadByte() -shl 16) -bor
                ([UInt64]$this.ReadByte() -shl 24) -bor
                ([UInt64]$this.ReadByte() -shl 32) -bor
                ([UInt64]$this.ReadByte() -shl 40))
        }
    }

    [UInt64] ReadUInt64(
        [bool] $isBigEndian
    ) {
        if ($isBigEndian) {
            return [UInt64](
                ([UInt64]$this.ReadByte() -shl 56) -bor
                ([UInt64]$this.ReadByte() -shl 48) -bor
                ([UInt64]$this.ReadByte() -shl 40) -bor
                ([UInt64]$this.ReadByte() -shl 32) -bor
                ([UInt64]$this.ReadByte() -shl 24) -bor
                ([UInt64]$this.ReadByte() -shl 16) -bor
                ([UInt64]$this.ReadByte() -shl 8) -bor
                $this.ReadByte())
        } else {
            return $this.ReadUInt64()
        }
    }

    [byte] PeekByte() {
        $value = $this.ReadByte()
        $this.BaseStream.Seek(-1, 'Current')
        return $value
    }

    [IPAddress] ReadIPAddress() {
        return [IPAddress]::new($this.ReadBytes(4))
    }

    [IPAddress] ReadIPv6Address() {
        return [IPAddress]::new($this.ReadBytes(16))
    }

    # http://www.ietf.org/rfc/rfc1035.txt
    [string] ReadDnsCharacterString() {
        $length = 0
        return $this.ReadDnsCharacterString([ref]$length)
    }

    [string] ReadDnsCharacterString(
        [ref] $Length
    ) {
        [Char[]]$escapeChars = @(
            92
            34
        )
        [Char[]]$replaceChars = @(
            10
            13
        )

        $stringLength = $this.ReadByte()
        $Length.Value = $stringLength + 1

        $string = [string]::new($this.ReadChars($stringLength))

        foreach ($escapeChar in $escapeChars) {
            $string = $string.Replace([string]$escapeChar, ('\{0}' -f $escapeChar))
        }
        foreach ($replaceChar in $replaceChars) {
            $string = $string.Replace([string]$replaceChar, ('\{0:000}' -f [Int]$replaceChar))
        }

        return $string
    }

    [UInt16[]] ReadBitMap(
        [int] $length
    ) {
        [UInt16[]]$bits = while ($length -gt 0) {
            $windowNumber = $this.ReadByte()
            $bitMapLength = $this.ReadByte()
            $bytes = $this.ReadBytes($bitMapLength)

            $binaryString = [StringBuilder]::new()
            foreach ($byte in $bytes) {
                $null = $binaryString.Append(
                    [Convert]::ToString($byte, 2).PadLeft(8, '0')
                )
            }

            for ($i = 0; $i -lt $binaryString.Length; $i++) {
                if ($binaryString[$i] -eq '1') {
                    $i + (256 * $windowNumber)
                }
            }

            $length -= 2 + $bitMapLength
        }

        return $bits
    }

    #   DNS messages implement compression to avoid bloat by repeated use of labels.
    #
    #   If a label occurs elsewhere in the message a flag is set and an offset recorded as follows:
    #
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    | 1  1|                OFFSET                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   http://www.ietf.org/rfc/rfc1035.txt
    #
    [string] ReadDnsDomainName() {
        $name = [StringBuilder]::new()
        [UInt64]$CompressionStart = 0

        if ($this.BaseStream.Position -eq $this.BaseStream.Length) {
            return ''
        }

        while ($this.PeekByte() -ne 0) {
            $length = $this.ReadByte()

            if (($length -band [MessageCompression]::Enabled) -eq [MessageCompression]::Enabled) {
                if ($compressionStart -eq 0) {
                    $compressionStart = $this.BaseStream.Position
                }

                # Remove the compression flag bits to calculate the offset value (relative to the start of the message)
                [UInt16]$offset = ([UInt16]($length -bxor [MessageCompression]::Enabled) -shl 8) -bor $this.ReadByte()
                $null = $this.BaseStream.Seek($offset, 'Begin')
            } else {
                $null = $name.Append($this.ReadChars($length)).Append('.')
            }
        }
        if ($compressionStart -gt 0) {
            $null = $this.BaseStream.Seek($compressionStart, 'Begin')
        }

        $null = $this.ReadByte()

        if ($name[-1] -ne '.') {
            $null = $name.Append('.')
        }

        $name = $name.ToString()
        if ($this.ConvertIdnToUnicode) {
            if ($name -eq '.') {
                return $name
            }
            if ($name -match 'xn--') {
                try {
                    return $this.idnMapping.GetUnicode($name)
                } catch {
                    return $name
                }
            } else {
                return $name
            }
        } else {
            return $name
        }
    }

    [string] ReadDnsDomainName(
        [ref] $Length
    ) {
        $start = $this.BaseStream.Position
        $value = $this.ReadDnsDomainName()
        $end = $this.BaseStream.Position
        $Length.Value = $end - $start

        return $value
    }

    #   RFC 1034:
    #
    #   "Internally, programs that manipulate domain names should represent them
    #    as sequences of labels, where each label is a length octet followed by
    #    an octet string.  Because all domain names end at the root, which has a
    #    null string for a label, these internal representations can use a length
    #    byte of zero to terminate a domain name."
    #
    #   RFC 1035:
    #
    #   "<domain-name> is a domain name represented as a series of labels, and
    #    terminated by a label with zero length.  <character-string> is a single
    #    length octet followed by that number of characters.  <character-string>
    #    is treated as binary information, and can be up to 256 characters in
    #    length (including the length octet)."
    #
    #   http://www.ietf.org/rfc/rfc1034.txt
    #   http://www.ietf.org/rfc/rfc1035.txt
    #
    static [byte[]] GetDnsDomainNameBytes(
        [string] $Name
    ) {
        # Drop any trailing . characters from the name. They are no longer necessary all names must be absolute by this point.
        $Name = $Name.TrimEnd('.')

        $bytes = [List[byte]]::new()
        if ($Name) {
            foreach ($label in $Name.Split('.')) {
                $bytes.Add($label.Length)
                $bytes.AddRange([byte[]][Char[]]$label)
            }
        }
        # Add a zero length root label
        $bytes.Add(0)

        return $bytes.ToArray()
    }
}
