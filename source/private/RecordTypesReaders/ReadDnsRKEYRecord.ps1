using namespace Indented.IO

function ReadDnsRKEYRecord {
    # .SYNOPSIS
    #   RKEY record parser.
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
    # .LINK
    #   http://tools.ietf.org/html/draft-reid-dnsext-rkey-00
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Flags
    $ResourceRecord | Add-Member Flags ($BinaryReader.ReadUInt16($true))
    # Property: Protocol
    $ResourceRecord | Add-Member Protocol ([Indented.DnsResolver.KEYProtocol]$BinaryReader.ReadByte())
    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([Indented.DnsResolver.EncryptionAlgorithm]$BinaryReader.ReadByte())
    # Property: PublicKey
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
    $ResourceRecord | Add-Member PublicKey ([Convert]::ToBase64String($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} ( {3} )' -f $this.Flags,
                                 [Byte]$this.Protocol,
                                 [Byte]$this.Algorithm,
                                 $this.PublicKey
    }
}