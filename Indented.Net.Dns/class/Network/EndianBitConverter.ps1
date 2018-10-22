using namespace System.Text

class EndianBitConverter {
    static [Byte[]] GetBytes(
        [UInt16]  $value, 
        [Boolean] $isLittleEndian
    ) {
        if ([BitConverter]::IsLittleEndian -and $isLittleEndian) {
            return [BitConverter]::GetBytes($value)
        } elseif ([BitConverter]::IsLittleEndian) {
            return [BitConverter]::GetBytes(
                [IPAddress]::HostToNetworkOrder([Int32]$value)
            )[2, 3]
        } else {
            return [BitConverter]::GetBytes($value)
        }
    }

    static [Byte[]] GetBytes(
        [UInt32]  $value,
        [Boolean] $isLittleEndian
    ) {
        if ([BitConverter]::IsLittleEndian -and $isLittleEndian) {
            return [BitConverter]::GetBytes($value)
        } elseif ([BitConverter]::IsLittleEndian) {
            return [BitConverter]::GetBytes(
                [IPAddress]::HostToNetworkOrder([Int64]$value)
            )[3..7]
        } else {
            return [BitConverter]::GetBytes($value)
        }
    }

    static [String] ToBinary(
        [Byte[]] $bytes
    ) {
        $string = [StringBuilder]::new()
        foreach ($byte in $bytes) {
            $string.Append(
                [Convert]::ToString($byte, 2).PadLeft(8, '0')
            )
        } 
        return $string.ToString()
    }
}