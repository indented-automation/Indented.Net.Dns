#region:TestFileHeader
param (
    [Boolean]$UseExisting
)

if (-not $UseExisting) {
    $moduleBase = $psscriptroot.Substring(0, $psscriptroot.IndexOf("\test"))
    $stubBase = Resolve-Path (Join-Path $moduleBase "test*\stub\*")
    if ($null -ne $stubBase) {
        $stubBase | Import-Module -Force
    }

    Import-Module $moduleBase -Force
}
#endregion

Describe Trace-Dns -Tag Integration {
    BeforeAll {
        $defaultParams = @{
            Name = 'www.indented.co.uk.'
        }
    }

    It 'Returns results from each name server' {
        $traceResponse = Trace-Dns @defaultParams

        @($traceResponse).Count | Should -BeGreaterThan 0
        $traceResponse[-1].Header.AnswerCount | Should -BeGreaterThan 0
    }
}