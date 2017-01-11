InModuleScope Indented.Net.Dns {
    Describe ConvertFromDnsDomainName {
        It 'Returns a single byte array' {
            ConvertFromDnsDomainName 'a' | Should BeOfType [Byte[]]
        }

        It 'Trims trailing periods' {
            Compare-Object (ConvertFromDnsDomainName 'a.') (1, 97, 0) | Should BeNullOrEmpty
        }

        It 'Pads names with a length byte set to 0' {
            Compare-Object (ConvertFromDnsDomainName '') @(0) | Should BeNullOrEmpty
            Compare-Object (ConvertFromDnsDomainName 'ab') (2, 97, 98, 0) | Should BeNullOrEmpty
        }
    }
}