using namespace System.Text

class EndianBitConverter {
    static [Byte[]] GetBytes([UInt16]$value, [Boolean]$isLittleEndian) {
        if ([BitConverter]::IsLittleEndian -and $isLittleEndian) {
            return [BitConverter]::GetBytes($value)
        } elseif ([BitConverter]::IsLittleEndian) {
            $value = [IPAddress]::HostToNetworkOrder($value)
            return [BitConverter]::GetBytes($value)
        } else {
            return [BitConverter]::GetBytes($value)
        }
    }

    static [Byte[]] GetBytes([UInt32]$value, [Boolean]$isLittleEndian) {
        if ([BitConverter]::IsLittleEndian -and $isLittleEndian) {
            return [BitConverter]::GetBytes($value)
        } elseif ([BitConverter]::IsLittleEndian) {
            $value = [IPAddress]::HostToNetworkOrder($value)
            return [BitConverter]::GetBytes($value)
        } else {
            return [BitConverter]::GetBytes($value)
        }
    }

    static [String] ToBinary([Byte[]]$bytes) {
        $string = [StringBuilder]::new()
        foreach ($byte in $bytes) {
            $string.Append(
                [Convert]::ToString($byte, 2).PadLeft(8, '0')
            )
        }
        return $string.ToString()
    }
}