using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsSIGRecord {
    # .SYNOPSIS
    #   SIG record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 TYPE COVERED                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       ALGORITHM       |         LABELS        |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                 ORIGINAL TTL                  |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |             SIGNATURE EXPIRATION              |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |              SIGNATURE INCEPTION              |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                    KEY TAG                    |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                 SIGNER'S NAME                 /
    #    /                                               /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                   SIGNATURE                   /
    #    /                                               /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc2535.txt
    #   http://www.ietf.org/rfc/rfc2931.txt
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

    # Property: TypeCovered
    $typeCovered = $BinaryReader.ReadUInt16($true)
    if ([Enum]::IsDefined([RecordType], $TypeCovered)) {
        $typeCovered = [RecordType]$TypeCovered
    } else {
        $typeCovered = 'UNKNOWN ({0})' -f $TypeCovered
    }
    $ResourceRecord | Add-Member TypeCovered $typeCovered
    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([EncryptionAlgorithm]$BinaryReader.ReadByte())
    # Property: Labels
    $ResourceRecord | Add-Member Labels $BinaryReader.ReadByte()
    # Property: OriginalTTL
    $ResourceRecord | Add-Member OriginalTTL $BinaryReader.ReadUInt32($true)
    # Property: SignatureExpiration
    $ResourceRecord | Add-Member SignatureExpiration ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true)))
    # Property: SignatureInception
    $ResourceRecord | Add-Member SignatureInception ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32($true)))
    # Property: KeyTags
    $ResourceRecord | Add-Member KeyTag $BinaryReader.ReadUInt16($true)
    # Property: SignersName
    $length = 0
    $ResourceRecord | Add-Member SignersName (ConvertToDnsDomainName $BinaryReader -BytesRead ([Ref]$length))
    # Property: Signature
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 18 - $length)
    $ResourceRecord | Add-Member Signature ([Convert]::ToBase64String($bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = '{0} {1} {2} ( ; type-cov={0}, alg={1}, labels={2}',
                  '    {3} ; Signature expiration',
                  '    {4} ; Signature inception',
                  '    {5} ; Key identifier',
                  '    {6} ; Signer',
                  '    {7} ; Signature',
                  ')' -join "`n"
        $string -f $this.TypeCovered,
                   [Byte]$this.Algorithm,
                   [Byte]$this.Labels,
                   $this.SignatureExpiration,
                   $this.SignatureInception,
                   $this.KeyTag,
                   $this.SignersName,
                   $this.Signature
    }
}