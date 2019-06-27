class DnsCSYNCRecord : DnsResourceRecord {
    <#
                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     SERIAL                    |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                     FLAGS                     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                 TYPE BIT MAP                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc7477.txt
    #>

    [RecordType]   $RecordType = [RecordType]::CSYNC
    [UInt32]       $Serial
    [CSYNCFlags]   $Flags
    [RecordType[]] $TypesToProcess


    DnsCSYNCRecord() : base() { }
    DnsCSYNCRecord(
        [DnsResourceRecord]  $dnsResourceRecord,
        [EndianBinaryReader] $binaryReader
    ) : base(
        $dnsResourceRecord,
        $binaryReader
    ) { }

    hidden [Void] ReadRecordData([EndianBinaryReader] $binaryReader) {
        $this.Serial = $binaryReader.ReadUInt32($true)
        $this.Flags = $binaryReader.ReadUInt16($true)

        $bitMapLength = $this.RecordDataLength - 6
        $bitMap = [EndianBitConverter]::ToBinary($binaryReader.ReadBytes($bitMapLength))
        $this.TypesToProcess = for ($i = 0; $i -lt $bitMap.Length; $i++) {
            if ($bitMap[$i] -eq 1) {
                [RecordType]$i
            }
        }

    }

    hidden [String] RecordDataToString() {
        $string = @(
            '{0} {1} ('
            '    {2} ; serial'
            '    {3} ; refresh ({4})'
            '    {5} ; retry ({6})'
            '    {7} ; expire ({8})'
            '    {9} ; minimum ttl ({10})'
            ')'
        ) -join "`n"
        return $string -f @(
            $this.NameServer,
            $this.ResponsiblePerson,
            $this.Serial.ToString().PadRight(10, ' '),
            $this.Refresh.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Refresh),
            $this.Retry.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Retry),
            $this.Expire.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.Expire),
            $this.MinimumTTL.ToString().PadRight(10, ' '),
            (ConvertTo-TimeSpanString -Seconds $this.MinimumTTL)
        )
    }

    hidden [IEnumerable[Byte]] RecordDataToByteArray(
        [Boolean] $useCompressedNames
    ) {
        $bytes = [List[Byte]]::new()

        if ($useCompressedNames) {
            # MNAME
            $bytes.AddRange([Byte[]](0xC0, 0x0C))
            # RNAME
            $bytes.AddRange([Byte[]](0xC0, 0x0C))
        } else {
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.NameServer))
            # RNAME
            $bytes.AddRange([EndianBinaryReader]::GetDnsDomainNameBytes($this.ResponsiblePerson))
        }

        # SerialNumber
        $bytes.AddRange([EndianBitConverter]::GetBytes($this.Serial, $true))
        $bytes.AddRange([Byte[]]::new(16))

        return ,$bytes
    }
}