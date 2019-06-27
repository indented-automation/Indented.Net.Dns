Describe Get-Dns -Tag Integration {
    BeforeAll {
        if (-not (Test-Path (Join-Path $psscriptroot 'bin\named.exe'))) {
            $params = @{
                Uri     = 'https://downloads.isc.org/isc/bind9/9.14.3/BIND9.14.3.x64.zip'
                OutFile = Join-Path $psscriptroot 'bin\BIND9.zip'
            }
            Invoke-WebRequest @params
            $params = @{
                Path            = $params.OutFile
                DestinationPath = Join-Path $psscriptroot 'bin'
            }
            Expand-Archive @params
        }

        $params = @{
            FilePath     = Join-Path $psscriptroot 'bin\named.exe'
            ArgumentList = @(
                '-c'
                '"{0}"' -f (Join-Path $psscriptroot 'data\named.conf')
                '-f'
            )
            PassThru     = $true
            RedirectStandardError = Join-Path $psscriptroot 'bin\error.log'
            RedirectStandardOutput = Join-Path $psscriptroot 'bin\out.log'
        }
        $process = Start-Process @params

        $defaultParams = @{
            ComputerName = '127.0.0.1'
            Port         = 1053
        }
    }

    AfterAll {
        $process | Stop-Process
    }

    It 'Generates RecordData matching dig' -TestCases @(
        @{ Name = 'a01'; RecordType = 'A' }
        @{ Name = 'a02'; RecordType = 'A' }
    ) {
        param (
            $Name,

            $RecordType
        )

        $Name = '{0}.test.indented.co.uk' -f $Name

        $getDnsResponse = Get-Dns -Name $Name -RecordType $RecordType @defaultParams
        $digResponse = & dig @(
            '+short'
            $RecordType
            $Name
            '@{0}' -f $defaultParams.ComputerName
        )

        $getDnsResponse.Header.RCode | Should -Be NoError
        $getDnsResponse.Answer.Count | Should -Be 1
        $getDnsResponse.Answer[0].RecordType | Should -Be $RecordType
        $getDnsResponse.Answer[0].RecordDataToString() | Should -Be $digResponse
    }
}