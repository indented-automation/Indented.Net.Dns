Describe Trace-Dns -Tag Integration {
    BeforeAll {
        $defaultParams = @{
            Name = 'www.indented.co.uk.'
        }
    }

    It 'Returns results from each name server' {
        if (-not $env:APPVEYOR) {
            $traceResponse = Trace-Dns @defaultParams

            @($traceResponse).Count | Should -BeGreaterThan 0
            $traceResponse[-1].Header.AnswerCount | Should -BeGreaterThan 0
        }
    }
}
