Describe Get-Dns -Tag Integration {
    Context 'Named' {
        BeforeAll {
            & (Join-Path $psscriptroot 'script\Start-NameServer.ps1')
            $dig = Join-Path $psscriptroot 'bin\dig.exe'

            $defaultParams = @{
                ComputerName = '127.0.0.1'
                Port         = 1053
            }
        }

        It 'Record data string for <Name> <RecordType> matches dig output' -TestCases @(
            @{ Name = 'a01';        RecordType = 'A' }
            @{ Name = 'a02';        RecordType = 'A' }
            @{ Name = '';           RecordType = 'NS' }
            @{ Name = 'cname01';    RecordType = 'CNAME' }
            @{ Name = 'cname02';    RecordType = 'CNAME' }
            @{ Name = 'cname03';    RecordType = 'CNAME' }
            @{ Name = '';           RecordType = 'SOA' }
            @{ Name = 'mb01';       RecordType = 'MB' }
            @{ Name = 'mb02';       RecordType = 'MB' }
            @{ Name = 'mg01';       RecordType = 'MG' }
            @{ Name = 'mg02';       RecordType = 'MG' }
            @{ Name = 'mr01';       RecordType = 'MR' }
            @{ Name = 'mr02';       RecordType = 'MR' }
            @{ Name = 'wks01';      RecordType = 'WKS' }
            @{ Name = 'wks02';      RecordType = 'WKS' }
            @{ Name = 'wks03';      RecordType = 'WKS' }
            @{ Name = 'ptr01';      RecordType = 'PTR' }
            @{ Name = 'hinfo01';    RecordType = 'HINFO' }
            @{ Name = 'hinfo02';    RecordType = 'HINFO' }
            @{ Name = 'minfo01';    RecordType = 'MINFO' }
            @{ Name = 'minfo02';    RecordType = 'MINFO' }
            @{ Name = 'mx01';       RecordType = 'MX' }
            @{ Name = 'mx02';       RecordType = 'MX' }
            @{ Name = 'txt01';      RecordType = 'TXT' }
            @{ Name = 'txt02';      RecordType = 'TXT' }
            @{ Name = 'txt03';      RecordType = 'TXT' }
            @{ Name = 'txt04';      RecordType = 'TXT' }
            @{ Name = 'txt05';      RecordType = 'TXT' }
            @{ Name = 'txt06';      RecordType = 'TXT' }
            @{ Name = 'txt07';      RecordType = 'TXT' }
            @{ Name = 'txt08';      RecordType = 'TXT' }
            @{ Name = 'txt09';      RecordType = 'TXT' }
            @{ Name = 'txt10';      RecordType = 'TXT' }
            @{ Name = 'txt11';      RecordType = 'TXT' }
            @{ Name = 'txt12';      RecordType = 'TXT' }
            @{ Name = 'txt13';      RecordType = 'TXT' }
            @{ Name = 'txt14';      RecordType = 'TXT' }
            @{ Name = 'txt15';      RecordType = 'TXT' }
            @{ Name = 'rp01';       RecordType = 'RP' }
            @{ Name = 'rp02';       RecordType = 'RP' }
            @{ Name = 'afsdb01';    RecordType = 'AFSDB' }
            @{ Name = 'afsdb02';    RecordType = 'AFSDB' }
            @{ Name = 'x2501';      RecordType = 'X25' }
            @{ Name = 'isdn01';     RecordType = 'ISDN' }
            @{ Name = 'isdn02';     RecordType = 'ISDN' }
            @{ Name = 'isdn03';     RecordType = 'ISDN' }
            @{ Name = 'isdn04';     RecordType = 'ISDN' }
            @{ Name = 'rt01';       RecordType = 'RT' }
            @{ Name = 'rt02';       RecordType = 'RT' }
            @{ Name = 'px01';       RecordType = 'PX' }
            @{ Name = 'px02';       RecordType = 'PX' }
            @{ Name = 'gpos01';     RecordType = 'GPOS' }
            @{ Name = 'gpos02';     RecordType = 'GPOS' }
            @{ Name = 'aaaa01';     RecordType = 'AAAA' }
            @{ Name = 'aaaa02';     RecordType = 'AAAA' }
            @{ Name = 'loc01';      RecordType = 'LOC' }
            @{ Name = 'loc02';      RecordType = 'LOC' }
            @{ Name = 'eid01';      RecordType = 'EID' }
            @{ Name = 'nimloc01';   RecordType = 'NIMLOC' }
            @{ Name = 'srv01';      RecordType = 'SRV' }
            @{ Name = 'srv02';      RecordType = 'SRV' }
            @{ Name = 'atma01';     RecordType = 'ATMA' }
            @{ Name = 'atma02';     RecordType = 'ATMA' }
            @{ Name = 'atma03';     RecordType = 'ATMA' }
            @{ Name = 'atma04';     RecordType = 'ATMA' }
            @{ Name = 'naptr01';    RecordType = 'NAPTR' }
            @{ Name = 'naptr02';    RecordType = 'NAPTR' }
            @{ Name = 'sig01';      RecordType = 'SIG' }
            @{ Name = 'key01';      RecordType = 'KEY' }
            @{ Name = 'kx01';       RecordType = 'KX' }
            @{ Name = 'kx02';       RecordType = 'KX' }
            @{ Name = 'cert01';     RecordType = 'CERT' }
            @{ Name = 'a601';       RecordType = 'A6' }
            @{ Name = 'a602';       RecordType = 'A6' }
            @{ Name = 'a603';       RecordType = 'A6' }
            @{ Name = 'a604';       RecordType = 'A6' }
            @{ Name = 'dname01';    RecordType = 'DNAME' }
            @{ Name = 'dname02';    RecordType = 'DNAME' }
            @{ Name = 'dname03';    RecordType = 'DNAME' }
            @{ Name = 'sink01';     RecordType = 'SINK' }
            @{ Name = 'sink02';     RecordType = 'SINK' }
            @{ Name = 'apl01';      RecordType = 'APL' }
            @{ Name = 'ds01';       RecordType = 'DS' }
            @{ Name = 'ds02';       RecordType = 'DS' }
            @{ Name = 'sshfp01';    RecordType = 'SSHFP' }
            @{ Name = 'sshfp02';    RecordType = 'SSHFP' }
            @{ Name = 'ipseckey01'; RecordType = 'IPSECKEY' }
            @{ Name = 'ipseckey02'; RecordType = 'IPSECKEY' }
            @{ Name = 'ipseckey03'; RecordType = 'IPSECKEY' }
            @{ Name = 'ipseckey04'; RecordType = 'IPSECKEY' }
            @{ Name = 'ipseckey05'; RecordType = 'IPSECKEY' }
            @{ Name = 'rrsig01';    RecordType = 'RRSIG' }
            @{ Name = 'nsec01';     RecordType = 'NSEC' }
            @{ Name = 'nsec02';     RecordType = 'NSEC' }
            @{ Name = 'nsec03';     RecordType = 'NSEC' }
            @{ Name = 'nsec04';     RecordType = 'NSEC' }
            @{ Name = 'dnskey01';   RecordType = 'DNSKEY' }
            @{ Name = 'dhcid01';    RecordType = 'DHCID' }
            @{ Name = 'dhcid02';    RecordType = 'DHCID' }
            @{ Name = 'dhcid03';    RecordType = 'DHCID' }
            @{ Name = '';           RecordType = 'NSEC3PARAM' }
            @{ Name = 'tlsa';       RecordType = 'TLSA' }
            @{ Name = 'smimea';     RecordType = 'SMIMEA' }
            @{ Name = 'hip1';       RecordType = 'HIP' }
            @{ Name = 'hip2';       RecordType = 'HIP' }
            @{ Name = 'ninfo01';    RecordType = 'NINFO' }
            @{ Name = 'ninfo02';    RecordType = 'NINFO' }
            @{ Name = 'ninfo03';    RecordType = 'NINFO' }
            @{ Name = 'ninfo04';    RecordType = 'NINFO' }
            @{ Name = 'ninfo05';    RecordType = 'NINFO' }
            @{ Name = 'ninfo06';    RecordType = 'NINFO' }
            @{ Name = 'ninfo07';    RecordType = 'NINFO' }
            @{ Name = 'ninfo08';    RecordType = 'NINFO' }
            @{ Name = 'ninfo09';    RecordType = 'NINFO' }
            @{ Name = 'ninfo10';    RecordType = 'NINFO' }
            @{ Name = 'ninfo11';    RecordType = 'NINFO' }
            @{ Name = 'ninfo12';    RecordType = 'NINFO' }
            @{ Name = 'ninfo13';    RecordType = 'NINFO' }
            @{ Name = 'ninfo14';    RecordType = 'NINFO' }
            @{ Name = 'ninfo15';    RecordType = 'NINFO' }
            @{ Name = 'rkey01';     RecordType = 'RKEY' }
            @{ Name = 'talink0';    RecordType = 'TALINK' }
            @{ Name = 'talink1';    RecordType = 'TALINK' }
            @{ Name = 'talink2';    RecordType = 'TALINK' }
            @{ Name = 'cds01';      RecordType = 'CDS' }
            @{ Name = 'cdnskey01';  RecordType = 'CDNSKEY' }
            @{ Name = 'openpgpkey'; RecordType = 'OPENPGPKEY' }
            @{ Name = 'csync01';    RecordType = 'CSYNC' }
            @{ Name = 'csync02';    RecordType = 'CSYNC' }
            @{ Name = 'zonemd01';   RecordType = 'ZONEMD' }
            @{ Name = 'spf01';      RecordType = 'SPF' }
            @{ Name = 'spf02';      RecordType = 'SPF' }
            @{ Name = 'nid';        RecordType = 'NID' }
            @{ Name = 'l32';        RecordType = 'L32' }
            @{ Name = 'l64';        RecordType = 'L64' }
            @{ Name = 'lp';         RecordType = 'LP' }
            @{ Name = 'eui48';      RecordType = 'EUI48' }
            @{ Name = 'eui64';      RecordType = 'EUI64' }
            @{ Name = 'uri01';      RecordType = 'URI' }
            @{ Name = 'uri02';      RecordType = 'URI' }
            @{ Name = 'uri03';      RecordType = 'URI' }
            @{ Name = 'caa01';      RecordType = 'CAA' }
            @{ Name = 'caa02';      RecordType = 'CAA' }
            @{ Name = 'caa03';      RecordType = 'CAA' }
            @{ Name = 'avc';        RecordType = 'AVC' }
            @{ Name = 'doa01';      RecordType = 'DOA' }
            @{ Name = 'doa02';      RecordType = 'DOA' }
            @{ Name = 'ta';         RecordType = 'TA' }
            @{ Name = 'dlv';        RecordType = 'DLV' }
            @{ Name = 'dlv';        RecordType = 'DLV' }
        ) {
            param (
                $Name,
                $RecordType
            )

            $Name = ('{0}.default.indented.co.uk' -f $Name).TrimStart('.')

            $getDnsResponse = Get-Dns -Name $Name -RecordType $RecordType @defaultParams
            $digResponse = & $dig @(
                '+short'
                $RecordType
                $Name
                '-p', $defaultParams.Port
                '@{0}' -f $defaultParams.ComputerName
            )

            $getDnsResponse.Header.RCode | Should -Be NoError
            $getDnsResponse.Answer.Count | Should -Be 1
            $getDnsResponse.Answer[0].RecordType | Should -Be $RecordType
            $getDnsResponse.Answer[0].RecordDataToString() | Should -Be $digResponse
        }

        It 'Record data string for <Name> <RecordType> matches dig output for ANY' -TestCases @(
            @{ Name = 'uinfo01';    RecordType = 'UINFO' }
            @{ Name = 'uid01';      RecordType = 'UID' }
            @{ Name = 'gid01';      RecordType = 'GID' }
            @{ Name = 'unspec01';   RecordType = 'UNSPEC' }
        ) {
            param (
                $Name,
                $RecordType,
                $Expect
            )

            $Name = ('{0}.default.indented.co.uk' -f $Name).TrimStart('.')

            $getDnsResponse = Get-Dns -Name $Name -RecordType $RecordType @defaultParams
            $digResponse = & $dig @(
                '+short'
                'ANY'
                $Name
                '-p', $defaultParams.Port
                '@{0}' -f $defaultParams.ComputerName
            )

            $getDnsResponse.Header.RCode | Should -Be NoError
            $getDnsResponse.Answer.Count | Should -Be 1
            $getDnsResponse.Answer[0].RecordType | Should -Be $RecordType
            $getDnsResponse.Answer[0].RecordDataToString() | Should -Be $digResponse
        }

        It 'Record data string for <Name> <RecordType> matches defined output' -TestCases @(
            @{ Name = 'amtrelay01'; RecordType = 'AMTRelay'; Expect = '10 0 1 203.0.113.15' }
            @{ Name = 'amtrelay02'; RecordType = 'AMTRelay'; Expect = '10 0 2 2001:DB8::15' }
            @{ Name = 'amtrelay03'; RecordType = 'AMTRelay'; Expect = '128 1 3 amtrelays.example.com.' }
        ) {
            param (
                $Name,
                $RecordType,
                $Expect
            )

            $Name = ('{0}.default.indented.co.uk' -f $Name).TrimStart('.')

            $getDnsResponse = Get-Dns -Name $Name -RecordType $RecordType @defaultParams

            $getDnsResponse.Header.RCode | Should -Be NoError
            $getDnsResponse.Answer.Count | Should -Be 1
            $getDnsResponse.Answer[0].RecordType | Should -Be $RecordType
            $getDnsResponse.Answer[0].RecordDataToString() | Should -Be $Expect
        }

        It 'Parses NSEC3 records in an authority section' {
            $Name = 'doesnotexist.signed.indented.co.uk'

            $getDnsResponse = Get-Dns -Name $Name -RecordType 'ANY' @defaultParams -DnsSec
            $getDnsResponse.Header.RCode | Should -Be NXDOMAIN
            $getDnsResponse.Authority.Count | Should -BeGreaterThan 0
            $nsec3Records = $getDnsResponse.Authority | Where-Object RecordType -eq 'NSEC3'

            $nsec3Records | Should -Not -BeNullOrEmpty
        }

        It 'DNSSEC responses include an OPT record in the additional section' {
            $Name = 'signed.indented.co.uk'

            $getDnsResponse = Get-Dns -Name $Name -RecordType 'ANY' @defaultParams -DnsSec
            $getDnsResponse.Header.RCode | Should -Be NoError
            $getDnsResponse.Additional.Count | Should -BeGreaterThan 0
            $optRecords = $getDnsResponse.Additional | Where-Object RecordType -eq 'OPT'

            $optRecords | Should -Not -BeNullOrEmpty
            $optRecords.Z | Should -Be 'DO'
        }
    }
}