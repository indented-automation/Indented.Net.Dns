Describe Search-Dns -Tag Integration {
    BeforeAll {
        $defaultParams = @{
            Name       = 'www.google.co.uk.'
            ZoneName   = 'google.co.uk.'
            RecordType = 'A'
        }
    }

    It 'Returns results from each name server' {
        if (-not $env:APPVEYOR) {
            $nsRecords = Get-Dns -Name $defaultParams.ZoneName -RecordType NS

            @(Search-Dns @defaultParams -Timeout 10).Count | Should -Be $nsRecords.Header.AnswerCount
        }
    }
}
