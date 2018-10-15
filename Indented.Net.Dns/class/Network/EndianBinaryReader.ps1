using namespace System.IO

class EndianBinaryReader : BinaryReader {
    EndianBinaryReader([Stream]$BaseStream) : base($BaseStream) { }

    [UInt16] ReadUInt16([Boolean]$isBigEndian) {
        return [UInt16](($this.ReadByte() -shl 8) -bor $this.ReadByte())
    }

    [UInt32] ReadUInt32([Boolean]$isBigEndian) {
        return [UInt32](
            ($this.ReadByte() -shl 24) -bor
            ($this.ReadByte() -shl 16) -bor
            ($this.ReadByte() -shl 8) -bor
            $this.ReadByte())
    }

    [UInt64] ReadUInt64([Boolean]$isBigEndian) {
        return [UInt64](
            ($this.ReadByte() -shl 56) -bor
            ($this.ReadByte() -shl 48) -bor
            ($this.ReadByte() -shl 40) -bor
            ($this.ReadByte() -shl 32) -bor
            ($this.ReadByte() -shl 24) -bor
            ($this.ReadByte() -shl 16) -bor
            ($this.ReadByte() -shl 8) -bor
            $this.ReadByte())
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

    [IPAddress] ReadIPv6Address()
    {
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
}
