class AngularDistance {
    [Int64]   $Degrees
    [Int64]   $Minutes
    [Decimal] $Seconds
    [String]  $Direction

    hidden static [Int32] $Equator = [Math]::Pow(2, 31)
    hidden static [Int32] $PrimeMeridian = [Math]::Pow(2, 31)

    AngularDistance([UInt32]$value, [DistanceType]$DistanceType) {
        $this.Direction = switch ($DistanceType) {
            'Latitude' {
                ('N', 'S')[$value -gt [AngularDistance]::Equator]
            }
            'Longitude' {
                ('W', 'E')[$value -gt [AngularDistance]::PrimeMeridian]
            }
        }

        $remainder = $value % (1000 * 60 * 60)
        $this.Degrees = ($value - $Remainder) / (1000 * 60 * 60)
        $value = $remainder

        $remainder = $value % (1000 * 60)
        $this.Minutes = ($value - $Remainder) / (1000 * 60)
        $value = $remainder

        $this.Seconds = $value / 1000
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