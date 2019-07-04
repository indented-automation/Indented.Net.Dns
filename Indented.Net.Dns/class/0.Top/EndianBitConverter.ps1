using namespace System.Text

class EndianBitConverter {
    static [Byte[]] GetBytes(
        [UInt16]  $value,
        [Boolean] $isBigEndian
    ) {
        if ([BitConverter]::IsLittleEndian -eq $isBigEndian) {
            return [BitConverter]::GetBytes(
                [IPAddress]::HostToNetworkOrder([Int32]$value)
            )[2, 3]
        } else {
            return [BitConverter]::GetBytes($value)
        }
    }

    static [Byte[]] GetBytes(
        [UInt32]  $value,
        [Boolean] $isBigEndian
    ) {
        if ([BitConverter]::IsLittleEndian -eq $isBigEndian) {
            return [BitConverter]::GetBytes(
                [IPAddress]::HostToNetworkOrder([Int64]$value)
            )[4..7]
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

    static [String] ToHexadecimal(
        [Byte[]] $bytes
    ) {
        $string = [StringBuilder]::new()
        foreach ($byte in $bytes) {
            $string.AppendFormat('{0:X2}' -f $byte)
        }
        return $string.ToString()
    }

    static [String] ToBase32String(
        [Byte[]] $bytes
    ) {
        $base32Characters = '0123456789ABCDEFGHIJKLMNOPQRSTUV'

        if ($bytes.Count -eq 0) {
            return ''
        }

        $binaryString = ''
        foreach ($byte in $bytes) {
            $binaryString += [Convert]::ToString($byte, 2).PadLeft(8, '0')
        }

        $chars = foreach ($value in $binaryString -split '(?<=\G.{5})') {
            if ($value) {
                $byte = [Convert]::ToByte($value.PadRight('0', 5), 2)
                $base32Characters[$byte]
            }
        }

        return [String]::new($chars)
    }
}