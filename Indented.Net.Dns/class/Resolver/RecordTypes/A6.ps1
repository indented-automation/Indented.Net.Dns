class A6 : DnsResourceRecord {
    <#
                                       1  1  1  1  1  1
         0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       |      PREFIX LEN       |                       |
       +--+--+--+--+--+--+--+--+                       |
       /                ADDRESS SUFFIX                 /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
       /                  PREFIX NAME                  /
       /                                               /
       +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #>
    
    [Byte]$PrefixLength

    [IPAddress]$AddressSuffix

    [String]$PrefixName

    A6() { }
    A6([EndianBinaryReader]$binaryReader) : base($binaryReader) { }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.PrefixLength = $binaryReader.ReadByte()

        $addressSuffixBytes = [Byte[]]::new(16)

        $length = [Math]::Ceiling((128 - $this.PrefixLength) / 8)
        $recordBytes = $binaryReader.ReadBytes($length)
        [Array]::Copy(
            $recordBytes,
            0,
            $addressSuffixBytes,
            16 - $length,
            $length
        )

        $this.AddressSuffix = [IPAddress]::new($addressSuffixBytes)
        $this.PrefixName = $binaryReader.ReadDnsDomainName()
    }

    Hidden [String] GetRecordData() {
        return '{0} {1} {2}' -f $this.PrefixLength,
                                $this.AddressSuffix.IPAddressToString,
                                $this.PrefixName
    }
}