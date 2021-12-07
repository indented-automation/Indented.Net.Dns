Describe AngularDistance {
    BeforeAll {
        $module = @{
            ModuleName = 'Indented.Net.Dns'
        }
    }

    It 'Converts a latitude value' {
        $latitude = InModuleScope @module {
            [AngularDistance]::new(2332934952, 'Latitude')
        }

        $latitude.Direction | Should -Be 'N'
        $latitude.Degrees | Should -Be 51
        $latitude.Minutes | Should -Be 30
        $latitude.Seconds | Should -Be 51.304
    }

    It 'Converts a longitude value' {
        $longitude = InModuleScope @module {
            [AngularDistance]::new(2147126743, 'Longitude')
        }

        $longitude.Direction | Should -Be 'W'
        $longitude.Degrees | Should -Be 0
        $longitude.Minutes | Should -Be 5
        $longitude.Seconds | Should -Be 56.905
    }
}
