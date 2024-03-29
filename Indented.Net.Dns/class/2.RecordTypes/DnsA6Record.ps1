class DnsA6Record : DnsResourceRecord {
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

    [byte]      $PrefixLength
    [IPAddress] $AddressSuffix
    [string]    $PrefixName

    DnsA6Record() : base() { }
    DnsA6Record(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [void] ReadRecordData(
        [EndianBinaryReader] $binaryReader
    ) {
        $this.PrefixLength = $binaryReader.ReadByte()

        $addressSuffixBytes = [byte[]]::new(16)

        $length = [Math]::Ceiling((128 - $this.PrefixLength) / 8)

        [Array]::Copy(
            $binaryReader.ReadBytes($length),
            0,
            $addressSuffixBytes,
            16 - $length,
            $length
        )

        $this.AddressSuffix = [IPAddress]::new($addressSuffixBytes)

        if ($this.RecordDataLength - $length - 1 -gt 0) {
            $this.PrefixName = $binaryReader.ReadDnsDomainName()
        }
    }

    hidden [string] RecordDataToString() {
        $ipAddress = '{0}' -f $this.AddressSuffix.IPAddressToString
        if ($ipAddress -eq '::') {
            $ipAddress = ''
        }

        return (
            '{0} {1} {2}' -f @(
                $this.PrefixLength
                $ipAddress
                $this.PrefixName
            )
        ).Trim()
    }
}
