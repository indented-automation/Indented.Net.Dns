using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Text

class EndianBinaryReader : BinaryReader {
    EndianBinaryReader([Stream]$BaseStream) : base($BaseStream) { }

    [UInt16] ReadUInt16([Boolean]$isBigEndian) {
        if ($isBigEndian) {
            return [UInt16](($this.ReadByte() -shl 8) -bor $this.ReadByte())
        } else {
            return $this.ReadUInt16()
        }
    }

    [UInt32] ReadUInt32([Boolean]$isBigEndian) {
        if ($isBigEndian) {
            return [UInt32](
                ($this.ReadByte() -shl 24) -bor
                ($this.ReadByte() -shl 16) -bor
                ($this.ReadByte() -shl 8) -bor
                $this.ReadByte())
        } else {
            return $this.ReadUInt32()
        }
    }

    [UInt64] ReadUInt64([Boolean]$isBigEndian) {
        if ($isBigEndian) {
            return [UInt64](
                ($this.ReadByte() -shl 56) -bor
                ($this.ReadByte() -shl 48) -bor
                ($this.ReadByte() -shl 40) -bor
                ($this.ReadByte() -shl 32) -bor
                ($this.ReadByte() -shl 24) -bor
                ($this.ReadByte() -shl 16) -bor
                ($this.ReadByte() -shl 8) -bor
                $this.ReadByte())
        } else {
            return $this.ReadUInt64()
        }
    }

    [Byte] PeekByte() {
        $value = $this.ReadByte()
        $this.BaseStream.Seek(-1, 'Current')
        return $value
    }

    [IPAddress] ReadIPAddress() {
        return [IPAddress]::new(
            $this.ReadByte(),
            $this.ReadByte(),
            $this.ReadByte(),
            $this.ReadByte()
        )
    }

    [IPAddress] ReadIPv6Address() {
        # Should use ctor for IPAddress
        return [IPAddress]::Parse(
            "{0:X}:{1:X}:{2:X}:{3:X}:{4:X}:{5:X}:{6:X}:{7:X}" -f 
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true),
                $this.ReadUInt16($true))
    }

    # http://www.ietf.org/rfc/rfc1035.txt
    [String] ReadDnsString() {
        $length = $this.ReadByte()
        return [String]::new($this.ReadChars($length))
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
    [String] ReadDnsDomainName() {
        $name = [StringBuilder]::new()
        [UInt64]$CompressionStart = 0

        $isCompressed = $false
        # Read until we find the null terminator
        while ($this.PeekByte() -ne 0) {
            # The length or compression reference
            $length = $this.ReadByte()
            # if (-not $isCompressed) {
            #     $BytesRead.Value++
            # }

            if (($length -band [MessageCompression]::Enabled) -eq [MessageCompression]::Enabled) {
                $isCompressed = $true

                # Record the current position as the start of the compression operation.
                # Reader will be returned here after this operation is complete.
                if ($compressionStart -eq 0) {
                    $compressionStart = $this.BaseStream.Position
                }
                # Remove the compression flag bits to calculate the offset value (relative to the start of the message)
                [UInt16]$offset = ([UInt16]($length -bxor [MessageCompression]::Enabled) -shl 8) -bor $this.ReadByte()
                # Move to the offset
                $null = $this.BaseStream.Seek($offset, 'Begin')
            } else {
                # Read a label
                $null = $name.Append($this.ReadChars($length))
                $null = $name.Append('.')

                # if (-not $isCompressed) {
                #     $BytesRead.Value += $length
                # }
            }
        }
        # If expansion was used, return to the starting point (plus 1 byte)
        if ($compressionStart -gt 0) {
            $null = $this.BaseStream.Seek($compressionStart, 'Begin')
        }
        # Read off and discard the null termination on the end of the name
        $null = $this.ReadByte()
        # $BytesRead.Value++

        if ($name[-1] -ne '.') {
            $null = $name.Append('.')
        }

        return $name.ToString()
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
    static [String] GetDnsDomainNameBytes([String]$Name) {
        # Drop any trailing . characters from the name. They are no longer necessary all names must be absolute by this point.
        $Name = $Name.TrimEnd('.')

        $bytes = [List[Byte]]::new()
        if ($Name) {
            foreach ($label in $Name.Split('.')) {
                $bytes.Add($label.Length)
                $bytes.AddRange([Char[]]$label)
            }
        }
        # Add a zero length root label
        $bytes.Add(0)

        return $bytes.ToArray()
    }
}
