using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns
using namespace System.Text
using namespace System.Collections.Generic

function ReadDnsOPTRecord {
    # .SYNOPSIS
    #   OPT record parser.
    # .DESCRIPTION
    #   OPT records make the following changes to standard resource record fields:
    #
    #   Field Name   Field Type     Description
    #   ----------   ----------     -----------
    #   NAME         domain name    empty (root domain)
    #   TYPE         u_int16_t      OPT
    #   CLASS        u_int16_t      sender's UDP payload size
    #   TTL          u_int32_t      extended RCODE and flags
    #   RDLEN        u_int16_t      describes RDATA
    #   RDATA        octet stream   {attribute,value} pairs
    # 
    #   The Extended RCODE (stored in the TTL) is formatted as follows:
    #  
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |    EXTENDED-RCODE     |        VERSION        |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                       Z                       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   RR data structure:
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  OPTION-CODE                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 OPTION-LENGTH                 |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  OPTION-DATA                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   Processing for each option assigned by IANA has been added as described below.
    #
    #   LLQ
    #   ---
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  OPTION-CODE                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 OPTION-LENGTH                 |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    VERSION                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  LLQ-OPCODE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  ERROR-CODE                   |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #    |                    LLQ-ID                     |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #    |                  LEASE-LIFE                   |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    # 
    #   NSID
    #   ----
    #
    #   Option data is returned as a byte array (NSIDBytes) and an ASCII string (NSIDString).
    #
    #   DUA, DHU and N3U
    #   ----------------
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  OPTION-CODE                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  LIST-LENGTH                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        ALG-CODE       |          ...          /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   EDNS-client-subnet
    #   ------------------
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                  OPTION-CODE                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 OPTION-LENGTH                 |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 ADDRESSFAMILY                 |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |    SOURCE NETMASK     |     SCOPE NETMASK     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #    /                    ADDRESS                    /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #  
    # .LINK
    #   http://www.ietf.org/rfc/rfc2671.txt
    #   http://files.dns-sd.org/draft-sekar-dns-llq.txt
    #   http://files.dns-sd.org/draft-sekar-dns-ul.txt
    #   http://www.ietf.org/rfc/rfc5001.txt
    #   http://www.ietf.org/rfc/rfc6975.txt
    #   http://www.ietf.org/id/draft-vandergaast-edns-client-subnet-02.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.
    
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: MaximumPayloadSize - A copy of the data held in Class
    $ResourceRecord | Add-Member MaximumPayloadSize $ResourceRecord.RecordClass
    # Property: ExtendedRCode
    $ResourceRecord | Add-Member ExtendedRCode ([RCode][UInt16]($ResourceRecord.TTL -shr 24))
    # Property: Version
    $ResourceRecord | Add-Member Version ($ResourceRecord.TTL -band 0x00FF0000)
    # Property: DNSSECOK
    $ResourceRecord | Add-Member DNSSECOK ([EDnsDNSSECOK]($ResourceRecord.TTL -band 0x00008000))
    
    $options = New-Object List[PSObject]

    $RecordDataLength = $ResourceRecord.RecordDataLength
    if ($RecordDataLength -gt 0) {
        do {
            $BinaryReader.SetMarker()

            $option = [PSCustomObject]@{
                OptionCode   = [EDnsOptionCode]$BinaryReader.ReadUInt16($true)
                OptionLength = $BinaryReader.ReadUInt16($true)
            }

            switch ($option.OptionCode) {
                ([EDnsOptionCode]::LLQ) {
                    # Property: Version
                    $option | Add-Member Version $BinaryReader.ReadUInt16($true)
                    # Property: OpCode
                    $option | Add-Member OpCode ([LLQOpCode]$BinaryReader.ReadUInt16($true))
                    # Property: ErrorCode
                    $option | Add-Member ErrorCode ([LLQErrorCode]$BinaryReader.ReadUInt16($true))
                    # Property: ID
                    $option | Add-Member ID $BinaryReader.ReadUInt64($true)
                    # Property: LeaseLife
                    $option | Add-Member LeaseLife $BinaryReader.ReadUInt32($true)

                    break
                }
                ([EDnsOptionCode]::UL) {
                    # Property: Lease
                    $option | Add-Member Lease $BinaryReader.ReadInt32($true)

                    break
                }
                ([EDnsOptionCode]::NSID) {
                    $bytes = $BinaryReader.ReadBytes($option.OptionLength)

                    # Property: Bytes
                    $option | Add-Member Bytes $bytes
                    # Property: String
                    $option | Add-Member String ([Encoding]::UTF8.GetString($bytes))

                    break
                }
                ([EDnsOptionCode]::EDNSClientSubnet) {
                    # Property: AddressFamily
                    $option | Add-Member AddressFamily ([IanaAddressFamily]$BinaryReader.ReadUInt16($true))
                    # Property: SourceNetMask
                    $option | Add-Member SourceNetMask $BinaryReader.ReadByte()
                    # Property: ScopeNetMask
                    $option | Add-Member ScopeNetMask $BinaryReader.ReadByte()

                    $addressLength = [Math]::Ceiling($option.SourceNetMask / 8)
                    $addressBytes = $BinaryReader.ReadBytes($addressLength)

                    $length = switch ($option.AddressFamily) {
                        ([IanaAddressFamily]::IPv4)                      { 4 }
                        ([Indented.DnsResolver.IanaAddressFamily]::IPv6) { 16 }
                    }
                    if ($length) {
                        while ($addressBytes.Length -lt $length) {
                            $addressBytes = @([Byte]0) + $addressBytes
                        }
                        $address = New-Object IPAddress $addressBytes
                    } else {
                        $address = $addressBytes
                    }

                    # Property: Address
                    $option | Add-Member Address -MemberType NoteProperty -Value $address

                    break
                }
                { $_ -in [EDnsOptionCode]::DAU, [EDnsOptionCode]::DHU, [EDnsOptionCode]::N3U } {
                    # Property: Algorithm
                    $option | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())
                    # Property: HashBytes
                    $bytes = $BinaryReader.ReadBytes($option.OptionLength)
                    $option | Add-Member HashBytes ([Convert]::ToBase64String($bytes))

                    break
                }
                default {
                    $option | Add-Member OptionData -MemberType NoteProperty -Value $BinaryReader.ReadBytes($option.OptionLength)
                }
            }

            $options.Add($option)

            $RecordDataLength = $RecordDataLength - $BinaryReader.BytesFromMarker
        } until ($RecordDataLength -eq 0)
    }

    # Property: Options - A container for individual options
    $ResourceRecord | Add-Member Options -Value $options.ToArray()
}