using namespace System.Text

class OPT : DnsResourceRecord {
    <#
        OPT records make the following changes to standard resource record fields:

        Field Name   Field Type     Description
        ----------   ----------     -----------
        NAME         domain name    empty (root domain)
        TYPE         u_int16_t      OPT
        CLASS        u_int16_t      sender's UDP payload size
        TTL          u_int32_t      extended RCODE and flags
        RDLEN        u_int16_t      describes RDATA
        RDATA        octet stream   {attribute,value} pairs

        The Extended RCODE (stored in the TTL) is formatted as follows:

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |    EXTENDED-RCODE     |        VERSION        |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                       Z                       |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        RR data structure:

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  OPTION-CODE                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 OPTION-LENGTH                 |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                  OPTION-DATA                  /
        /                                               /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        Processing for each option assigned by IANA has been added as described below.

        LLQ
        ---

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  OPTION-CODE                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 OPTION-LENGTH                 |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    VERSION                    |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  LLQ-OPCODE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  ERROR-CODE                   |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                    LLQ-ID                     |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  LEASE-LIFE                   |
        |                                               |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        NSID
        ----

        Option data is returned as a byte array (NSIDBytes) and an ASCII string (NSIDString).

        DUA, DHU and N3U
        ----------------

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  OPTION-CODE                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  LIST-LENGTH                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |        ALG-CODE       |          ...          /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        EDNS-client-subnet
        ------------------

                                        1  1  1  1  1  1
          0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                  OPTION-CODE                  |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 OPTION-LENGTH                 |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |                 ADDRESSFAMILY                 |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        |    SOURCE NETMASK     |     SCOPE NETMASK     |
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
        /                    ADDRESS                    /
        +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

        http://www.ietf.org/rfc/rfc2671.txt
        http://files.dns-sd.org/draft-sekar-dns-llq.txt
        http://files.dns-sd.org/draft-sekar-dns-ul.txt
        http://www.ietf.org/rfc/rfc5001.txt
        http://www.ietf.org/rfc/rfc6975.txt
        http://www.ietf.org/id/draft-vandergaast-edns-client-subnet-02.txt
    #>

    [UInt16]         $MaximumPayloadSize
    [UInt16]         $ExtendedRCode
    [UInt32]         $Version
    [EDnsDNSSECOK]   $Z
    [PSObject[]]     $OptionData

    OPT() { }

    [Void] ReadRecordData([EndianBinaryReader]$binaryReader) {
        $this.MaximumPayloadSize = $this.RecordClass
        $this.ExtendedRCode = [RCode][UInt16]($this.TTL -shr 24)
        $this.Version = $this.TTL -band 0x00FF0000
        $this.DNSSECOK = [EDnsDNSSECOK]($this.TTL -band 0x00008000)

        $optionsLength = $this.RecordDataLength

        $this.OptionData = while ($optionsLength -gt 0) {
            $optionCode   = [EDnsOptionCode]$binaryReader.ReadUInt16($true)
            $optionLength = $binaryReader.ReadUInt16($true)
            $optionsLength -= $optionLength

            switch ($optionCode) {
                'LLQ' {
                    [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        Version      = $binaryReader.ReadUInt16($true)
                        OpCode       = [LLQOpCode]$binaryReader.ReadUInt16($true)
                        ErrorCode    = [LLQErrorCode]$BinaryReader.ReadUInt16($true)
                        ID           = $binaryReader.ReadUInt64($true)
                        LeaseLife    = $binaryReader.ReadUInt32($true)
                    }
                    break
                }
                'UL' {
                    [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        Lease        = $binaryReader.ReadInt32($true)
                    }
                    break
                }
                'NSID' {
                    $bytes = $binaryReader.ReadBytes($this.OptionLength)
                    [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        Bytes        = $bytes
                        String       = [Encoding]::UTF8.GetString($bytes)
                    }
                    break
                }
                'EDNSClientSubnet' {
                    $option = [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        AddressFamily = [IanaAddressFamily]$binaryReader.ReadUInt16($true)
                        SourceNetMask = $binaryReader.ReadByte()
                        ScopeNetMask  = $binaryReader.ReadByte()
                        Address       = $null
                    }

                    $addressLength = [Math]::Ceiling($option.SourceNetMask / 8)
                    $addressBytes = $BinaryReader.ReadBytes($addressLength)

                    $length = switch ($option.AddressFamily) {
                        'IPv4' { 4 }
                        'IPv6' { 16 }
                    }
                    if ($length) {
                        while ($addressBytes.Length -lt $length) {
                            $addressBytes = @([Byte]0) + $addressBytes
                        }
                        $option.Address = [IPAddress]::new($addressBytes)
                    } else {
                        $option.Address = $addressBytes
                    }
                    $option

                    break
                }
                { $_ -in 'DAU', 'DHU', 'N3U' } {
                    [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        Algorithm    = [EncryptionAlgorithm]$binaryReader.ReadByte()
                        HashBytes    = [Convert]::ToBase64String($binaryReader.ReadBytes($optionLength - 1))
                    }
                    break
                }
                default {
                    [PSCustomObject]@{
                        OptionCode   = $optionCode
                        OptionLength = $optionLength
                        OptionData   = $binaryReader.ReadBytes($optionLength)
                    }
                }
            }
        }
    }
}