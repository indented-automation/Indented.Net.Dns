using namespace Indented
using namespace Indented.IO
using namespace Indented.Net.Dns

function ReadDnsNSEC3Record {
    # .SYNOPSIS
    #   NSEC3 record parser.
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
    #    |       HASH LEN        |                       /
    #    +--+--+--+--+--+--+--+--+                       /
    #    /                      HASH                     /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    /                                               /
    #    /                   <BIT MAP>                   /
    #    /                                               /
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #
    #   The flags field takes the following format, discussed in RFC 5155 3.2:
    #
    #      0  1  2  3  4  5  6  7 
    #    +--+--+--+--+--+--+--+--+
    #    |                    |O |
    #    +--+--+--+--+--+--+--+--+
    #
    #   Where O, bit 7, represents the Opt-Out Flag.
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

    # Property: OptOut
    $ResourceRecord | Add-Member OptOut ([Boolean]($this.Flags -band [NSEC3Flags]::OutOut))

    # Property: Iterations
    $ResourceRecord | Add-Member Iterations $BinaryReader.ReadUInt16($true)

    # Property: SaltLength
    $ResourceRecord | Add-Member SaltLength $BinaryReader.ReadByte()

    # Property: Salt
    $salt = ''
    if ($ResourceRecord.SaltLength -gt 0) {
        $salt = [Convert]::ToBase64String($BinaryReader.ReadBytes($ResourceRecord.SaltLength))
    }
    $ResourceRecord | Add-Member Salt $salt

    # Property: HashLength
    $ResourceRecord | Add-Member HashLength $BinaryReader.ReadByte()

    # Property: Hash
    $ResourceRecord | Add-Member Hash ([Convert]::ToBase64String($BinaryReader.ReadBytes($ResourceRecord.HashLength)))

    # Property: RRTypeBitMap
    $length = $ResourceRecord.RecordDataLenght - 6 - $ResourceRecord.SaltLength - $ResourceRecord.HashLength
    $bytes = $BinaryReader.ReadBytes($length)
    $ResourceRecord | Add-Member RRTypeBitMap ([EndianBitConverter]::ToBinary($bytes))

    # Property: RRTypes
    $rrTypes = New-Object List[String]
    foreach ($rrType in [Enum]::GetValues([RecordType])) {
        if ($ResourceRecord.RRTypeBitMap[[Int]$rrType] -eq 1) {
            $rrTypes.Add($rrType)
        }
    }
    $ResourceRecord | Add-Member RRTypes $rrTypes.ToArray()

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        $string = '{0} {1} {2} {3} (', '{4} {5} )' -join "`n"
        $string -f [Byte]$this.HashAlgorithm,
                   $this.Flags,
                   $this.Iterations,
                   $this.Salt,
                   $this.Hash,
                   ($this.RRTypes -join ' ')
    }
}
