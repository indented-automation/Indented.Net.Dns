using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsSSHFPRecord {
    # .SYNOPSIS
    #   SSHFP record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       ALGORITHM       |        FPTYPE         |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                  FINGERPRINT                  /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc4255.txt
    # .NOTES
    #   Change log:
    #     09/03/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Algorithm
    $ResourceRecord | Add-Member Algorithm ([SSHAlgorithm]$BinaryReader.ReadByte())
    # Property: FPType
    $ResourceRecord | Add-Member FPType ([SSHFPType]$BinaryReader.ReadByte())
    # Property: Fingerprint
    $bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 2)
    $ResourceRecord | Add-Member Fingerprint ([EndianBitConverter]::ToString(,$bytes))

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2}' -f [Byte]$this.Algorithm,
                         [Byte]$this.FPType,
                         $this.Fingerprint
    }
}