using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsCERTRecord {
    # .SYNOPSIS
    #   CERT record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                     TYPE                      |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    KEY TAG                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       ALGORITHM       |                       |
    #    +--+--+--+--+--+--+--+--+                       |
    #    /               CERTIFICATE or CRL              /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc4398.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: CertificateType
    $ResourceRecord | Add-Member CertificateType ([CertificateType]$Reader.ReadUInt16($true))
    
    # Property: KeyTag
    $ResourceRecord | Add-Member KeyTag $Reader.ReadUInt16($true)
    
    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$Reader.ReadByte())
    
    # Property: Certificate
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
    $ResourceRecord | Add-Member Certificate ([Convert]::ToBase64String($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}' -f $this.CertificateType.ToString(),
                             [UInt16]$this.KeyTag,
                             [UInt16]$this.Algorithm,
                             $this.Certificate
    }
}
