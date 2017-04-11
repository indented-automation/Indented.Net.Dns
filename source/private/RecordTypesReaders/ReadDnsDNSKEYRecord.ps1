using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsDNSKEYRecord {
    # .SYNOPSIS
    #   DNSKEY record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     FLAGS                     |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        PROTOCOL       |       ALGORITHM       |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  PUBLIC KEY                   /
    #    /                                               /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   The flags field takes the following format, discussed in RFC 4034 2.1.1:
    #
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    | Z|                    | S|
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    #   Where Z represents the ZoneKey bit, and S the SecureEntryPoint bit.
    # .LINK
    #   http://www.ietf.org/rfc/rfc3755.txt
    #   http://www.ietf.org/rfc/rfc4034.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Flags
    $ResourceRecord | Add-Member Flags ($BinaryReader.ReadUInt16($true))
    
    # Property: ZoneKey (bit 7 of Flags)
    $ResourceRecord | Add-Member ZoneKey -MemberType ScriptProperty -Value {
        [Boolean]($this.Flags -band 0x0100)
    }
    
    # Property: SecureEntryPoint (bit 15 of Flags)
    $ResourceRecord | Add-Member SecureEntryPoint -MemberType ScriptProperty -Value {
        [Boolean]($this.Flags -band 0x0001)
    }

    # Property: Protocol
    $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([KEYProtocol]$BinaryReader.ReadByte())

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())

    # Property: PublicKey
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
    $ResourceRecord | Add-Member PublicKey ([Convert]::ToBase64String($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} ( {3} )' -f $this.Flags,
                                 [Byte]$this.Protocol,
                                 [Byte]$this.Algorithm,
                                 $this.PublicKey
    }
}
