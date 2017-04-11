using namespace Indented.IO

function ReadDnsLOCRecord {
    # .SYNOPSIS
    #   LOC record parser.
    # .DESCRIPTION
    #                                    1  1  1  1  1  1
    #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |        VERSION        |         SIZE          |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |       HORIZ PRE       |       VERT PRE        |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   LATITUDE                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   LONGITUDE                   |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    #    |                   ALTITUDE                    |
    #    |                                               |
    #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
    #
    # .LINK
    #   http://www.ietf.org/rfc/rfc1876.txt
    # .NOTES
    #   Change log:
    #     09/02/2017 - Chris Dent - Modernisation pass.

    [OutputType([Void])]
    param(
        [EndianBinaryReader]$BinaryReader,

        [PSTypeName('Indented.Net.Dns.ResourceRecord')]
        $ResourceRecord
    )

    # Property: Version
    $ResourceRecord | Add-Member Version $BinaryReader.ReadByte()

    # Property: Size - Default is 100m
    $byte = $BinaryReader.ReadByte()
    $size = (($byte -band 0xF0 -shr 4) * [Math]::Pow(10, ($byte -band 0x0F))) / 100
    $ResourceRecord | Add-Member Size $size

    # Property: HorizontalPrecision - Default value is 10000m
    $byte = $BinaryReader.ReadByte()
    $horizontalPrecision = (($byte -band 0xF0 -shr 4) * [Math]::Pow(10, ($byte -band 0x0F))) / 100
    $ResourceRecord | Add-Member HorizontalPrecision $horizontalPrecision

    # Property: VerticalPrecision - Default value is 10m
    $byte = $BinaryReader.ReadByte()
    $verticalPrecision = (($byte -band 0xF0 -shr 4) * [Math]::Pow(10, ($byte -band 0x0F))) / 100
    $ResourceRecord | Add-Member VerticalPrecision $verticalPrecision

    # Property: LatitudeRawValue
    $ResourceRecord | Add-Member LatitudeRawValue $BinaryReader.ReadUInt32($true)
    
    # Property: Latitude
    $ResourceRecord | Add-Member Latitude -MemberType ScriptProperty -Value {
        $equator = [Math]::Pow(2, 31)
        if ($this.LatitudeRawValue -gt $Equator) {
            $direction = "S"
        } else {
            $direction = "N"
        }
        $value = $this.LatitudeRawValue

        # Degrees
        $remainder = $value % (1000 * 60 * 60)
        $degrees = ($value - $Remainder) / (1000 * 60 * 60)
        $value = $remainder
        
        # Minutes
        $remainder = $value % (1000 * 60)
        $minutes = ($value - $Remainder) / (1000 * 60)
        $value = $remainder
        
        # Seconds
        $seconds = $value / 1000

        '{0} {1} {2} {3}' -f $degrees,
                             $minutes,
                             $seconds,
                             $direction
    }

    # Property: LatitudeToString
    $ResourceRecord | Add-Member LatitudeToString -MemberType ScriptProperty -Value {
        '{0} degrees {1} minutes {2} seconds {3}' -f $this.Latitude.Split(' ')
    }

    # Property: LongitudeRawValue
    $ResourceRecord | Add-Member LongitudeRawValue $BinaryReader.ReadUInt32($true)

    # Property: Longitude
    $ResourceRecord | Add-Member Longitude -MemberType ScriptProperty -Value {
        $primeMeridian = [Math]::Pow(2, 31)
        if ($this.LongitudeRawValue -gt $PrimeMeridian) {
            $direction = 'E'
        } else {
            $direction = 'W'
        }
        $value = $this.LongitudeRawValue

        # Degrees
        $remainder = $value % (1000 * 60 * 60)
        $degrees = ($value - $remainder) / (1000 * 60 * 60)
        $value = $remainder

        # Minutes
        $remainder = $value % (1000 * 60)
        $minutes = ($value - $remainder) / (1000 * 60)
        $value = $remainder

        # Seconds
        $seconds = $value / 1000

        '{0} {1} {2} {3}' -f $degrees,
                             $minutes,
                             $seconds,
                             $direction
    }

    # Property: LongitudeToString
    $ResourceRecord | Add-Member LongitudeToString -MemberType ScriptProperty -Value {
        '{0} degrees {1} minutes {2} seconds {3}' -f $this.Longitude.Split(' ')
    }

    # Property: Altitude
    $ResourceRecord | Add-Member Altitude ($BinaryReader.ReadUInt32($true) / 100)

    # Property: RecordData
    $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
        '{0} {1} {2} {3}m {4}m {5}m' -f $this.Latitude,
                                        $this.Longitude,
                                        $this.Altitude,
                                        $this.Size,
                                        $this.HorizontalPrecision,
                                        $this.VerticalPrecision
    }
}
