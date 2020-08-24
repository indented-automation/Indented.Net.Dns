class AngularDistance {
    [Int64]   $Degrees
    [Int64]   $Minutes
    [Decimal] $Seconds
    [String]  $Direction

    hidden static [Int64] $Equator = 2147483648
    hidden static [Int64] $PrimeMeridian = 2147483648

    AngularDistance([UInt32]$value, [DistanceType]$distanceType) {
        $this.Direction = switch ($distanceType) {
            'Latitude' {
                ('S', 'N')[$value -gt [AngularDistance]::Equator]
            }
            'Longitude' {
                ('W', 'E')[$value -gt [AngularDistance]::PrimeMeridian]
            }
        }

        $value = [Math]::Abs($value - 2147483648)

        $remainder = $value % (1000 * 60 * 60)
        $this.Degrees = ($value - $remainder) / (1000 * 60 * 60)
        $value = $remainder

        $remainder = $value % (1000 * 60)
        $this.Minutes = ($value - $remainder) / (1000 * 60)
        $value = $remainder

        $this.Seconds = $value / 1000
    }

    [UInt32] ToUInt32() {
        $value = (
            ($this.Seconds * 1000) +
            ($this.Minutes * 1000 * 60) +
            ($this.Degrees * 1000 * 60 * 60)
        )

        if ($this.Direction -in 'N', 'E') {
            $value = 2147483648 + $value
        } else {
            $value = 2147483648 - $value
        }

        return $value
    }

    [String] ToString() {
        return '{0} {1} {2:N3} {3}' -f @(
            $this.Degrees
            $this.Minutes
            $this.Seconds
            $this.Direction
        )
    }

    [String] ToLongString() {
        return '{0} degrees {1} minutes {2:N3} seconds {3}' -f @(
            $this.Degrees
            $this.Minutes
            $this.Seconds
            $this.Direction
        )
    }
}
