using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsNSEC3PARAMRecord {
    # .SYNOPSIS
    #   NSEC3PARAM record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       HASH ALG        |         FLAGS         |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   ITERATIONS                  |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       SALT LEN        |                       /
    #    +--+--+--+--+--+--+--+--+                       /
    #    /                      SALT                     /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc5155.txt
    # .NOTES
    #   Change log:
    #     08/03/2017 - Chris Dent - Modernisation pass.
    
    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: HashAlgorithm
    $ResourceRecord | Add-Member HashAlgorithm ([NSEC3HashAlgorithm]$BinaryReader.ReadByte())

    # Property: Flags
    $ResourceRecord | Add-Member Flags $BinaryReader.ReadByte()
    
    # Property: Iterations
    $ResourceRecord | Add-Member Iterations $BinaryReader.ReadUInt16($true)
    
    # Property: SaltLength
    $ResourceRecord | Add-Member SaltLength $BinaryReader.ReadByte()
    
    # Property: Salt
    $salt = ''
    if ($ResouceRecord.SaltLength -gt 0) {
        $salt = [EndianBitConverter]::ToString($BinaryReader.ReadBytes($ResourceRecord.SaltLength)
    }
    $ResourceRecord | Add-Member Salt $salt

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}' -f [Byte]$this.HashAlgorithm,
                             $this.Flags,
                             $this.Iterations,
                             $this.Salt
    }
}
