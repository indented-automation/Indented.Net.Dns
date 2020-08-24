InModuleScope Indented.Net.Dns {
    Describe ConvertToTimeSpanString {
        It 'Converts <Value> to <String>' -TestCases @(
            @{ Value = 1;       String = '1 second' }
            @{ Value = 60;      String = '1 minute' }
            @{ Value = 3600;    String = '1 hour' }
            @{ Value = 86400;   String = '1 day' }
            @{ Value = 604800;  String = '1 week' }
            @{ Value = 2;       String = '2 seconds' }
            @{ Value = 120;     String = '2 minutes' }
            @{ Value = 7200;    String = '2 hours' }
            @{ Value = 172800;  String = '2 days' }
            @{ Value = 1209600; String = '2 weeks' }
            @{ Value = 612001;  String = '1 week 2 hours 1 second' }
        ) {
            param (
                [UInt32]$Value,

                [String]$String
            )

            ConvertToTimeSpanString -Seconds $Value | Should -Be $String
        }
    }
}
